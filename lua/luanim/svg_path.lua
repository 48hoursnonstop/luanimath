-- Source-derived SVG path conversion: svg_mobject.py and svgelements.Arc.
local V=require('luanim.vector')
local U=require('luanim.util')
local B=require('luanim.bezier')
local P={}
function P.reader(text)
    assert(type(text)=='string','path data must be a string')
    local r={text=text,pos=1}
    function r:skip() local _,last=self.text:find('^[%s,]*',self.pos);self.pos=(last or self.pos-1)+1 end
    function r:peek() self:skip();return self.text:sub(self.pos,self.pos) end
    function r:number()
        self:skip();local start=self.pos
        local function ch() return self.text:sub(self.pos,self.pos) end
        if ch()=='+' or ch()=='-' then self.pos=self.pos+1 end
        local digits=0
        while ch():match('%d') do digits=digits+1;self.pos=self.pos+1 end
        if ch()=='.' then self.pos=self.pos+1;while ch():match('%d') do digits=digits+1;self.pos=self.pos+1 end end
        assert(digits>0,'expected SVG number at byte '..start)
        if ch()=='e' or ch()=='E' then
            self.pos=self.pos+1;if ch()=='+' or ch()=='-' then self.pos=self.pos+1 end
            local exponent=self.pos;while ch():match('%d') do self.pos=self.pos+1 end
            assert(self.pos>exponent,'invalid SVG exponent')
        end
        return U.number(tonumber(self.text:sub(start,self.pos-1)),'SVG number')
    end
    function r:flag() local flag=self:peek();assert(flag=='0' or flag=='1','SVG arc flag must be 0 or 1');self.pos=self.pos+1;return flag=='1' end
    return r
end
local function append_arc(points,start,rx,ry,rotation,large,sweep,finish,drawn)
    rx,ry=math.abs(rx),math.abs(ry)
    if V.close(start,finish,0) or rx==0 or ry==0 then return drawn end
    local phi=rotation*(math.pi/180);local c,s=math.cos(phi),math.sin(phi)
    local dx,dy=(start[1]-finish[1])/2,(start[2]-finish[2])/2
    local x,y=c*dx+s*dy,-s*dx+c*dy
    local radius=x*x/(rx*rx)+y*y/(ry*ry)
    if radius>1 then local scale=math.sqrt(radius);rx=rx*scale;ry=ry*scale end
    local t1,t2=rx*rx*(y*y),ry*ry*(x*x)
    local factor=math.sqrt(math.abs((rx*rx*(ry*ry)-t1-t2)/(t1+t2)))*(large==sweep and -1 or 1)
    local cxp,cyp=factor*rx*y/ry,-factor*ry*x/rx
    local cx=c*cxp-s*cyp+(start[1]+finish[1])/2
    local cy=s*cxp+c*cyp+(start[2]+finish[2])/2
    local a=math.atan((y-cyp)/ry,(x-cxp)/rx)
    local ux,uy,vx,vy=(x-cxp)/rx,(y-cyp)/ry,(-x-cxp)/rx,(-y-cyp)/ry
    local dot=(ux*vx+uy*vy)/math.sqrt((ux*ux+uy*uy)*(vx*vx+vy*vy))
    local degrees=math.acos(U.clamp(dot,-1,1))*(180/math.pi)
    if ux*vy-uy*vx<0 then degrees=-degrees end
    degrees=degrees%360;if not sweep then degrees=degrees-360 end
    local angle=degrees*(math.pi/180)
    local n=math.max(1,math.ceil(math.abs(angle)/(2*math.pi*.1)))
    local step=angle/n;local previous=V(drawn)
    for i=1,n do
        local t=a+i*step;local mid=t-step/2
        local alpha=(4-math.cos(step))/3
        local handle=V(cx+alpha*(rx*math.cos(mid)*c-ry*math.sin(mid)*s),cy+alpha*(rx*math.cos(mid)*s+ry*math.sin(mid)*c),0)
        local endpoint=i==n and V(finish) or V(cx+rx*math.cos(t)*c-ry*math.sin(t)*s,cy+rx*math.cos(t)*s+ry*math.sin(t)*c,0)
        B.append(points,{previous,(previous+handle*2)/3,(handle*2+endpoint)/3,endpoint});previous=endpoint
    end
    return previous
end
function P.parse(text)
    local r=P.reader(text);local points={};local pen=V();local start=nil
    local command,previous,cubic,quad,drawn
    while r:peek()~='' do
        local token=r:peek()
        if token:match('[A-Za-z]') then command=token;r.pos=r.pos+1 end
        assert(command and command:match('^[MmLlHhVvCcSsQqTtAaZz]$'),'unsupported or missing SVG path command')
        local relative=command==command:lower();local code=command:upper();local original=pen
        local function point() local v=V(r:number(),r:number(),0);return relative and v+original or v end
        if code=='M' then pen=point();start=V(pen);drawn=V(pen);command=relative and 'l' or 'L'
        elseif code=='Z' then
            assert(start,'close requires a subpath');if V.norm(drawn-start)>.0001 then B.append(points,B.line(drawn,start)) end
            pen=V(start);drawn=V(start);command=nil
        else
            assert(start,'SVG path must start with MoveTo')
            if code=='L' then pen=point();B.append(points,B.line(drawn,pen));drawn=pen
            elseif code=='H' then local x=r:number();pen=V(relative and original[1]+x or x,original[2],0);B.append(points,B.line(drawn,pen));drawn=pen
            elseif code=='V' then local y=r:number();pen=V(original[1],relative and original[2]+y or y,0);B.append(points,B.line(drawn,pen));drawn=pen
            elseif code=='C' or code=='S' then
                local h1=code=='C' and point() or ((previous=='C' or previous=='S') and original*2-cubic or V(original))
                local h2=point();pen=point();B.append(points,{drawn,h1,h2,pen});cubic=h2;drawn=pen
            elseif code=='Q' or code=='T' then
                local h=code=='Q' and point() or ((previous=='Q' or previous=='T') and original*2-quad or V(original))
                pen=point();B.append(points,{drawn,(drawn+h*2)/3,(h*2+pen)/3,pen});quad=h;drawn=pen
            elseif code=='A' then
                local rx,ry,angle=r:number(),r:number(),r:number();local large,sweep=r:flag(),r:flag()
                pen=point();drawn=append_arc(points,original,rx,ry,angle,large,sweep,pen,drawn)
            end
        end
        previous=code
    end
    return points
end
return P
