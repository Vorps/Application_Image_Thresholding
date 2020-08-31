classdef ThresholdEditor < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure;
        UIAxes;
        pathImage;
        addComponentName;
        list;
        bases; defaultBases;index;
        baseR;baseG;baseB;basePlus;
        image;
        threshold1Slider, threshold2Slider;
        threshold1, threshold2;
        threshold1CheckBox; threshold2CheckBox;
        UIAxesHistogram;
        addButton, removeButton;
        baseRDropDown;baseGDropDown;baseBDropDown; 
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            
            app.bases = {Base('Red', [1,0,0,0]), Base('Green', [0,1,0,0]), Base('Blue', [0,0,1,0])};
            
            app.UIFigure = uifigure('Visible', 'off', 'WindowState', 'maximized', 'Name', 'Threshold Editor');

            grid = uigridlayout(app.UIFigure, 'ColumnWidth',  {700, '1x'}, 'RowHeight',  {'1x', 80});
            
            app.UIAxes = uiaxes(grid);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Layout.Row = [1 2];
            app.UIAxes.Layout.Column = 2;
            app.UIAxes.XColor = 'none';
            app.UIAxes.XTick = [];
            app.UIAxes.YColor = 'none';
            app.UIAxes.YTick = [];
            app.UIAxes.ZColor = 'none';
            app.UIAxes.ZTick = [];
            
            gridImage = uigridlayout(grid, 'RowHeight', {32,32,'1x'}, 'ColumnWidth', {85, '1x', 32});

            gridImage.Layout.Row = 1;
            gridImage.Layout.Column = 1;
            
            gridBase = uigridlayout(gridImage, 'RowHeight', {32, 40,40, 32, '1x'}, 'ColumnWidth', {50, 70, 50, 70, 50, 70,20, 50,'1x'});
            basesTmp = horzcat({'R', 'G', 'B'},cellfun(@(x) x.name,app.bases,'UniformOutput',false));
            
            app.baseRDropDown = uidropdown(gridBase, 'Items', basesTmp);
            app.baseRDropDown .Layout.Column = 2;
            app.baseR = uieditfield(gridBase, 'numeric', 'ValueChangedFcn',  @(txt, event) app.changeImage());
            app.baseR.Layout.Column = 1;

            app.baseGDropDown = uidropdown(gridBase, 'Items', basesTmp, 'Value', 'G');
            app.baseGDropDown .Layout.Column = 4;
            app.baseG = uieditfield(gridBase, 'numeric', 'ValueChangedFcn',  @(txt, event) app.changeImage());
            app.baseG.Layout.Column = 3;
            app.baseBDropDown = uidropdown(gridBase, 'Items', basesTmp, 'Value', 'B');
            app.baseBDropDown .Layout.Column = 6;
            app.baseB = uieditfield(gridBase, 'numeric', 'ValueChangedFcn',  @(txt, event) app.changeImage());
            app.baseB.Layout.Column = 5;
           
            baseplusLabel = uilabel(gridBase, 'Text', '+');
            baseplusLabel.Layout.Column = 7;
            app.basePlus = uieditfield(gridBase, 'numeric', 'ValueChangedFcn',  @(txt, event) app.changeImage());
            app.basePlus.Layout.Column = 8;
            
            app.threshold1Slider = uislider(gridBase, 'ValueChangedFcn', @(sld,event) app.threshold_11());
            app.threshold1Slider.Layout.Row = 2;
            app.threshold1Slider.Layout.Column = [1,9];
            app.threshold1Slider.Limits = [0 255];

            app.threshold1CheckBox = uicheckbox(gridBase, 'Text', 'Threshold_1', 'ValueChangedFcn',  @(txt, event) app.changeImage());
            app.threshold1CheckBox.Layout.Row = 4;
            app.threshold1CheckBox.Layout.Column = [1 2];

            app.threshold1 = uieditfield(gridBase, 'numeric', 'ValueChangedFcn',  @(txt, event) app.threshold_21());
            app.threshold1.Layout.Row = 4;
            app.threshold1.Layout.Column = 3;



            app.threshold2Slider = uislider(gridBase, 'ValueChangedFcn', @(sld,event) app.threshold_12());
            app.threshold2Slider.Layout.Row = 3;
            app.threshold2Slider.Layout.Column = [1,9];
            app.threshold2Slider.Limits = [0 255];

            app.threshold2CheckBox = uicheckbox(gridBase, 'Text', 'Threshold_2', 'ValueChangedFcn',  @(txt, event) app.changeImage());
            app.threshold2CheckBox.Layout.Row = 4;
            app.threshold2CheckBox.Layout.Column = [4 5];

            app.threshold2 = uieditfield(gridBase, 'numeric', 'ValueChangedFcn',  @(txt, event) app.threshold_22());
            app.threshold2.Layout.Row = 4;
            app.threshold2.Layout.Column = 6;

  

            gridBase.Layout.Row = 3;
            gridBase.Layout.Column = [2 3];
            app.UIAxesHistogram = uiaxes(gridBase);
            app.UIAxesHistogram.Layout.Row = 5;
            app.UIAxesHistogram.Layout.Column = [1,9];

            EditFieldLabel = uilabel(gridImage, 'Text', 'Image source');
            EditFieldLabel.Layout.Row = 1;
            EditFieldLabel.Layout.Column = 1;

            app.pathImage = uieditfield(gridImage, 'text', 'ValueChangedFcn', @(txt, event) app.textPathImageChanged(txt));
            app.pathImage.Layout.Row = 1;
            app.pathImage.Layout.Column = 2;

            Button = uibutton(gridImage, 'push', 'Icon', 'resources/logo.png', 'Text', '', 'ButtonPushedFcn', @(s,event) app.getImage());
            Button.Layout.Row = 1;
            Button.Layout.Column = 3;

            app.removeButton = uibutton(gridImage, 'push', 'Icon', 'resources/remove.png', 'Text', '', 'ButtonPushedFcn', @(s,event) app.removeComponent());
            app.removeButton.Layout.Row = 2;
            app.removeButton.Layout.Column = 3;
            set(app.removeButton,'Enable','off')
            
            app.addButton = uibutton(gridImage, 'push', 'Icon', 'resources/add.png', 'Text', '', 'ButtonPushedFcn', @(s,event) app.addComponent());
            app.addButton.Layout.Row = 2;
            app.addButton.Layout.Column = 1;
            set(app.addButton,'Enable','off')


            app.addComponentName = uieditfield(gridImage, 'text', 'ValueChangedFcn', @(txt, event) app.textComponentChanged(txt));
            app.addComponentName.Layout.Row = 2;
            app.addComponentName.Layout.Column = 2;


            app.list = uilistbox(gridImage, 'ValueChangedFcn', @(s,event) app.updateSelect());

            app.list.Layout.Row = 3;
            app.list.Layout.Column = 1;
            
            app.list.Items = cellfun(@(x) x.name,app.bases,'UniformOutput',false);

            app.index = 1;
            app.changeBase()

            app.UIFigure.Visible = 'on';
        end

        function threshold_11(app)
            app.threshold1.Value = round(app.threshold1Slider.Value);
            app.changeImage();
        end

        function threshold_21(app)
            if(app.threshold1.Value > 0)
                app.threshold1Slider.Value = app.threshold1.Value;
            else
                app.threshold1Slider.Value = 0;
                app.threshold1.Value = 0;
            end
            app.changeImage();
            
        end


        function threshold_12(app)
            app.threshold2.Value = round(app.threshold2Slider.Value);
            app.changeImage();
        end

        function threshold_22(app)
            if(app.threshold2.Value > 0)
                app.threshold2Slider.Value = app.threshold2.Value;
            else
                app.threshold2Slider.Value = 0;
                app.threshold2.Value = 0;
            end
            app.changeImage();
            
        end

        function updateSelect(app)
            % Interface graphique faut le dire vite fait 
            if ~isempty(app.list.Value)
                app.index = sum(contains(app.list.Items, app.list.Value).*(1:length(app.list.Items)));
                app.changeBase();
                set(app.removeButton,'Enable','on')
            else
                 set(app.removeButton,'Enable','off')
            end
        end


        function changeImage(app, image)
              if(nargin == 2)
                app.image = image;
              end
              if(~isempty(app.image))
                app.bases{app.index}.base = [app.baseR.Value, app.baseG.Value, app.baseB.Value, app.basePlus.Value];
                app.bases{app.index}.threshold1 = app.threshold1.Value;
                app.bases{app.index}.threshold2 = app.threshold2.Value;
                [n,m,t] = size(app.image);
                imageBase = zeros(n,m, 'int16');
                i = 1;
                for base = {app.baseRDropDown, app.baseGDropDown, app.baseBDropDown}
                    switch(base{:}.Value)
                    case 'R'
                        imageBase = imageBase + app.bases{app.index}.base(i)*int16(app.image(:,:,1));
                    case 'G'
                        imageBase = imageBase + app.bases{app.index}.base(i)*int16(app.image(:,:,2));
                    case 'B'
                        imageBase = imageBase + app.bases{app.index}.base(i)*int16(app.image(:,:,3));
                    otherwise
                       imageBase = imageBase + app.bases{app.index}.base(i)*int16(app.bases{sum(contains(app.list.Items, base{:}.Value).*(1:length(app.list.Items)))}.image);
                    end
                    i = i + 1;
                end
                imageBase = imageBase + app.bases{app.index}.base(4);
                if (app.threshold1CheckBox.Value == 1 && app.threshold2CheckBox.Value == 1)
                    imageBaseBin  = imageBase > app.threshold1Slider.Value & imageBase < app.threshold2Slider.Value;
                elseif (app.threshold1CheckBox.Value == 1)
                    imageBaseBin = imageBase > app.threshold1Slider.Value;
                elseif(app.threshold2CheckBox.Value == 1) 
                    imageBaseBin  = imageBase < app.threshold2Slider.Value;
                  else 
                    imageBaseBin = uint8(imageBase);
                end
                imshow(imageBaseBin, 'Parent', app.UIAxes);
                app.bases{app.index}.image = imageBaseBin;
                histogram(double(int16(imageBase)), 'Parent', app.UIAxesHistogram);
                hold(app.UIAxesHistogram, 'on' )
                xline(app.threshold1Slider.Value, '-r', 'Parent', app.UIAxesHistogram);
                xline(app.threshold2Slider.Value, '-b', 'Parent', app.UIAxesHistogram);
               hold(app.UIAxesHistogram, 'off' )
              end
        end

        function changeBase(app)
            app.baseR.Value = app.bases{app.index}.base(1);
            app.baseG.Value = app.bases{app.index}.base(2);
            app.baseB.Value = app.bases{app.index}.base(3);
            app.basePlus.Value = app.bases{app.index}.base(4);
            app.threshold1Slider.Value = app.bases{app.index}.threshold1;
            app.threshold_12();
            app.threshold2Slider.Value = app.bases{app.index}.threshold2;
            app.threshold_22();
            app.changeImage();
        end

        function textPathImageChanged(app, txt)
            if(isfile(txt.Value))
                app.changeImage(imread(txt.Value));
            end
        end
        
        function textComponentChanged(app, txt)
            if(ischar(txt.Value) && sum(contains(app.list.Items,txt.Value)) == 0)
                set(app.addButton,'Enable','on')
            else
                set(app.addButton,'Enable','off')
            end
        end

        function getImage(app)
                [file, path] = uigetfile({'*.png;*.jpg;*.bmp;*.tif','Supported images';...
                 '*.png','Portable Network Graphics (*.png)';...
                 '*.jpg','J-PEG (*.jpg)';...
                 '*.bmp','Bitmap (*.bmp)';...
                 '*.tif','Tagged Image File (*.tif,)';...
                 '*.*','All files (*.*)'});
                file = fullfile(path, file);
                disp(file)
                if(isfile(file))
                    app.changeImage(imread(file));
                    app.pathImage.Value = file;
                end
        end
        
        function addComponent(app)
            text = app.addComponentName.Value;
            if(ischar(text) && sum(contains(app.list.Items,text)) == 0)
                app.bases =  horzcat(app.bases,{Base(text, [0,0,0,0])});
                app.index = length(app.bases);
                app.list.Items = [app.list.Items , text];
            end
            app.addComponentName.Value = '';
        end
        
        function removeComponent(app)
            app.index = 1;
            app.list.Items(length(app.list.Items)) = [];
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ThresholdEditor

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end