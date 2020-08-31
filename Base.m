classdef Base
    properties
        name;
        base;
        threshold1;
        threshold2;
        image;
    end

     methods
        function obj = Base(name, base)
            obj.name =name;
            obj.base = base;
            obj.threshold1 = 0;
            obj.threshold2 = 0;
        end
     end
end