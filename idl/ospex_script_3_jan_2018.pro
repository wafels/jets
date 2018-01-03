; OSPEX script created Wed Jan  3 10:24:56 2018 by OSPEX writescript method.                 
;                                                                                            
;  Call this script with the keyword argument, obj=obj to return the                         
;  OSPEX object reference for use at the command line as well as in the GUI.                 
;  For example:                                                                              
;     ospex_script_3_jan_2018, obj=obj                                                       
;                                                                                            
;  Note that this script simply sets parameters in the OSPEX object as they                  
;  were when you wrote the script, and optionally restores fit results.                      
;  To make OSPEX do anything in this script, you need to add some action commands.           
;  For instance, the command                                                                 
;     obj -> dofit, /all                                                                     
;  would tell OSPEX to do fits in all your fit time intervals.                               
;  See the OSPEX methods section in the OSPEX documentation at                               
;  http://hesperia.gsfc.nasa.gov/ssw/packages/spex/doc/ospex_explanation.htm                 
;  for a complete list of methods and their arguments.                                       
;                                                                                            
pro ospex_script_3_jan_2018, obj=obj                                                         
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                        
obj-> set, spex_specfile= '/home/ireland/jets/jets/idl/hsi_spectrum_20121120_080002.fits'    
obj-> set, spex_drmfile= '/home/ireland/jets/jets/idl/hsi_srm_20121120_080002.fits'          
obj-> set, spex_source_angle= 57.5363                                                        
obj-> set, spex_source_xy= [781.850, -211.619]                                               
obj-> set, spex_fit_time_interval= ['20-Nov-2012 08:06:30.000', $                            
 '20-Nov-2012 08:14:02.000']                                                                 
obj-> set, spex_bk_order=1                                                                   
obj-> set, spex_bk_time_interval=[['20-Nov-2012 08:02:54.000', '20-Nov-2012 08:06:30.000'], $
 ['20-Nov-2012 08:13:06.000', '20-Nov-2012 08:15:38.000']]                                   
obj-> set, fit_comp_params= [0.00154329, 0.777323, 1.00000]                                  
obj-> set, spex_autoplot_bksub= 0                                                            
obj-> set, spex_autoplot_overlay_back= 0                                                     
obj-> set, spex_autoplot_units= 'Flux'                                                       
obj-> set, spex_eband= [[3.00000, 6.00000], [6.00000, 12.0000], [12.0000, 25.0000], $        
 [25.0000, 50.0000], [50.0000, 100.000], [100.000, 300.000]]                                 
obj-> set, spex_tband= [['20-Nov-2012 08:00:02.000', '20-Nov-2012 08:03:59.000'], $          
 ['20-Nov-2012 08:03:59.000', '20-Nov-2012 08:07:56.000'], ['20-Nov-2012 08:07:56.000', $    
 '20-Nov-2012 08:11:53.000'], ['20-Nov-2012 08:11:53.000', '20-Nov-2012 08:15:50.000']]      
obj -> restorefit, file='/home/ireland/jets/jets/idl/ospex_results_3_jan_2018.fits'          
end                                                                                          
