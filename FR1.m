classdef FR1 < experiment
    properties
       type 
    end
    
    methods
        function obj = FR1(BASE_DIR , expInfo , type)
            obj@experiment(BASE_DIR , expInfo);
            obj.type = type;
        end
        
    end
    
end