"""Return contracts for the documented public surface."""
GEOMETRY={'Mobject','VMobject','VGroup','Group','Arc','Circle','Dot','Ellipse','Line','Polygon','Rectangle','Square','RegularPolygon','Triangle','CubicBezier','ValueTracker','VectorizedPoint','Text','MarkupText','SVGMobject','VMobjectFromSVGPath','NumberLine','Axes','ParametricFunction','FunctionGraph','ThreeDVMobject','Cube','Sphere','Surface','always_redraw','Typst','MathTypst','ArcBetweenPoints','Polygram','RoundedRectangle'}
ANIMATIONS={'Animation','Create','Uncreate','Write','Unwrite','DrawBorderThenFill','FadeIn','FadeOut','Transform','ReplacementTransform','Rotate','MoveAlongPath','GrowFromPoint','GrowFromCenter','GrowFromEdge','SpinInFromNothing','MoveToTarget','ApplyMethod','ApplyFunction','ApplyPointwiseFunction','ApplyMatrix','FadeToColor','ScaleInPlace','ShrinkToCenter','Restore'}
PATHS={'straight_path','path_along_arc','path_along_circles','clockwise_path','counterclockwise_path','spiral_path'}
TYPES={
 'Mobject:generate_target':'Mobject',
 'Mobject:get_arc_center':'vector','Mobject:stop_angle':'number','Mobject:get_vertices':'vector[]','Mobject:get_vertex_groups':'vector[][]',
 'LinearBase':'Scale','LogBase':'Scale','Scale:map':'number or number[]','Scale:inverse':'number or number[]',
 'typst_to_svg_file':'string','config.with':'...','Mobject:select':'VGroup','Mobject:get_baseline_frame':'vector, vector, vector','Mobject:get_baseline_frames':'vector[3][]','Mobject:get_color':'RGBA or nil',
 'vec':'vector','font_list':'string[]','parse':'RGBA','interpolate':'RGBA','color_gradient':'RGBA[]',
 'builder':'AnimationBuilder','Mobject:animate':'AnimationBuilder',
 'Mobject:get_family':'Mobject[]','Mobject:family_members_with_points':'Mobject[]','Mobject:split':'Mobject[]',
 'Mobject:slice':'Mobject','Mobject:copy':'Mobject','Mobject:get_point_mobject':'Mobject','Mobject:get_subcurve':'Mobject',
 'Mobject:get_all_points':'vector[]','Mobject:get_points_defining_boundary':'vector[]','Mobject:get_anchors':'vector[]','Mobject:get_start_anchors':'vector[]','Mobject:get_end_anchors':'vector[]','Mobject:get_subpaths':'vector[][]',
 'Mobject:get_critical_point':'vector','Mobject:get_center':'vector','Mobject:get_left':'vector','Mobject:get_right':'vector','Mobject:get_top':'vector','Mobject:get_bottom':'vector','Mobject:get_start':'vector','Mobject:get_end':'vector','Mobject:get_last_point':'vector','Mobject:point_from_proportion':'vector','Mobject:get_location':'vector','Mobject:get_origin':'vector','Mobject:get_point_from_function':'vector',
 'Mobject:length_over_dim':'number','Mobject:get_width':'number','Mobject:get_height':'number','Mobject:get_depth':'number','Mobject:get_length':'number','Mobject:get_angle':'number','Mobject:get_num_curves':'integer','Mobject:get_arc_length':'number','Mobject:get_font_size':'number','Mobject:get_value':'number','Mobject:get_unit_size':'number',
 'Mobject:is_closed':'boolean','Mobject:has_new_path_started':'boolean','Mobject:number_to_point':'vector or vector[]','Mobject:point_to_number':'number or number[]','Mobject:coords_to_point':'vector or vector[]','Mobject:point_to_coords':'number[2] or number[2][]',
 'Mobject:get_tick_range':'number[]','Mobject:get_tick':'Mobject','Mobject:get_tick_marks':'VGroup','Mobject:get_axes':'VGroup','Mobject:plot':'Mobject','Mobject:get_function':'function',
 'Scene:render':'RenderReport','Renderer:close':'nil','Renderer.encode':'nil',
 'Camera:copy':'Camera','Camera:get_value_trackers':'ValueTracker[]','Camera:rotate_point':'vector','Camera:generate_rotation_matrix':'number[3][3]','Camera:project_point':'vector','Camera:project_points':'vector[]','Camera:transform_points':'vector[]','Camera:depth':'number','Camera:shading':'table or nil',
 'vec.dot':'number','vec.norm':'number','vec.close':'boolean','vec.cross':'vector','vec.normalize':'vector','vec.lerp':'vector','vec.rotate':'vector',
 'bezier.point':'vector','bezier.split':'vector[4], vector[4]','bezier.partial':'vector[4]','bezier.length':'number','bezier.curves':'vector[4][]','bezier.append':'nil','bezier.line':'vector[4]','bezier.remap':'vector[]','bezier.subpaths':'vector[][]','bezier.smooth':'vector[]','bezier.partial_path':'vector[]','config.resolve':'table',
}
def returns(name):
    if name in TYPES:return TYPES[name]
    if name in GEOMETRY:return 'Mobject'
    if name in ANIMATIONS or name.startswith('Animation:'):return 'Animation'
    if name in ('AnimationGroup','LaggedStart','Succession') or name.startswith('AnimationGroup:'):return 'AnimationGroup'
    if name in ('Scene','MovingCameraScene','ThreeDScene') or name.startswith('Scene:'):return 'Scene'
    if name in ('Camera','MovingCamera','ThreeDCamera') or name.startswith('Camera:'):
        if name.startswith('Camera:get_'):
            if name=='Camera:get_frame_center':return 'vector'
            return 'number'
        return 'Camera'
    if name in ('Renderer','Renderer:render'):return 'Renderer'
    if name in PATHS:return 'function(start_points,end_points,alpha) -> vector[]'
    if name.startswith('Mobject:'):return 'Mobject'
    if name in ('linear','smooth','smoothstep','smootherstep','smoothererstep','rush_into','rush_from','slow_into','double_smooth','there_and_back'):return 'number'
    raise AssertionError('missing return contract: '+name)
