% HSICUBE - A convenient object-oriented way to manage working with
% hyperspectral data sets.  
%
% This class sets up a number of methods to make using the cubes easier.
% Some of the functionalities are specific to working with the Denali 
% dataset, and as such, mileage may vary in using them with other datasets.
%
% One of the main functionalities is that it can load up the full cube,
% panel or just the materials of the Denali dataset.
%
%
% Written by Andrew Pound (c) 2012 for USU HIP Team.
classdef hsicube < dynamicprops  
    % Handle class or not? > A handle class, because this is the main block of
    % information for an HSIdataset
    % I want to be able to add dynamic properties...
    properties
        cubepixelmean
        panelpixelmean
        
        materialLocalOffsets        
    end
    
    properties ( SetAccess = private)
        matdir
        cubedir
        paneldir
        

    end % Properties
    
    properties (Constant = true)
        % There is only one for all objects.
        
    end % Constant Properties
    
    properties ( SetAccess = private)  % Meant this to be immutable, but ...
        % These properties can only be set in the constructor.
        
        % Cube properties that can't change:
        cubesize        % The size of the original cube
        cubedate        % Datenum of the date and time of this cube
        wavelengths     % Wavelength values
        
        % Filenames:
        matfname        % Matlab filename
        cubefname       % Origianl filename
        panelfname      % Panel filename
        
%        t               % Original information structure
    end % Immutable Properties
    
    properties( Dependent )
        cubefilename    % This is dependent, because it gets built from 
                        % cubedir and cubefname
        matfilename
        panelfilename
        
        time            % Time returned as a 1x3 vector.
        date            % Date returned as a 1x6 vector.
    end
    
    methods
        % Constructor:
        function obj = hsicube(arg1)
            % hsicube:hsicube Constructor for the hsicube class.  The
            % kosher way to initialize hsicube is using a cubeinfo
            % structure at the moment. This should change at some point.
            %
            
            % How can we initialize this? 
                if nargin > 0
                    % Make sure that the argument is a struct.
                    if isstruct(arg1) && all(isfield(arg1,{'cubesize','cubedate',...
                                                        'origdir','origfname',...
                                                        'matdir','matfname',...
                                                        'paneldir','panelfname'}))
                                                    
                        [m n] = size(arg1);
                        
                        obj(m,n) = hsicube;
                        for i = 1:m
                            for j = 1:n
                            
                                % Initialize the immutable properties:
                                obj(i,j).cubesize    = arg1(i,j).cubesize;
                                obj(i,j).cubedate    = arg1(i,j).cubedate;
                                obj(i,j).wavelengths = [];
                                
                                obj(i,j).matfname    = arg1(i,j).matfname;
                                obj(i,j).cubefname   = arg1(i,j).origfname;
                                obj(i,j).panelfname  = arg1(i,j).panelfname;

                                % Initialize the rest of the properties:
                                obj(i,j).matdir      = arg1(i,j).matdir;
                                obj(i,j).cubedir     = arg1(i,j).origdir;
                                obj(i,j).paneldir    = arg1(i,j).paneldir;
                                obj(i,j).cubepixelmean  = [];
                                obj(i,j).panelpixelmean = [];
                                
                            end
                        end
                    else
                        error('Problem Constructing hsicube.  arg1 isn''t a struct')
                    end

                else
                    % Set any immutable properties....
                end
        end
        
        % Set methods...
        function set.matdir(obj, value)  % What are the issues here???
            if ischar(value) && exist(value,'dir')
                obj.matdir = value;
            elseif isempty(value)
                obj.matdir = [];
            else
               warning('Error setting the material directory...')
            end
        end
        function set.cubedir(obj, value)
            if ischar(value) && exist(value,'dir')
                obj.cubedir = value;
            elseif isempty(value)
                obj.cubedir = [];
            else
                warning('Error setting the cube directory...')
            end
        end
        function set.paneldir(obj, value)
            if ischar(value) && exist(value,'dir')
                obj.paneldir = value;
            elseif isempty(value)
                obj.paneldir = [];
            else
                warning('Error setting the panel directory...')
            end
        end
        function value = get.cubefilename(obj)
            value = fullfile(obj.cubedir, obj.cubefname);
        end
        function value = get.matfilename(obj)
            value = fullfile(obj.matdir, obj.matfname);
        end
        function value = get.panelfilename(obj)
            value = fullfile(obj.paneldir, obj.panelfname);
        end
        
        % Convenience
        function value = get.time(obj)
            value = datevec(obj.cubedate);
            value = value(:,4:end);            
        end
        function value =get.date(obj)
            value = datevec(obj.cubedate);
        end
        
        function out = getTimes(obj,flag)
            % hsicube:getTimes This function returns the time of the
            % cube(s).  A logical flag may be passed in to return MATLAB
            % datenums if true.
            if ~isa(obj,'hsicube')
                error('Input must be an hsicube object...');
            end
            if nargin < 2
                flag = 0;
            end
            switch flag
                case 1
                    if isscalar(obj) 
                        out = datenum(obj.time);
                    else
                        out = datenum(cell2mat({obj(:).time}.'));
                    end
                otherwise
                    if isscalar(obj) 
                        out = obj.time;
                    else
                        out = cell2mat({obj(:).time}.');                
                    end
            end
                    
        end
        
        function out = getDates(obj,flag)
            % hsicube:getDates This function returns the date of the
            % cube(s). A logical flag may be passed in to return MATLAB
            % datenums if true.
            if ~isa(obj,'hsicube')
                error('Input must be an hsicube object...');
            end
            if nargin < 2
                flag = 0;
            end
            switch flag
                case 1
                    if isscalar(obj) 
                        out = datenum(obj.date);
                    else
                        out = datenum(cell2mat({obj(:).date}.'));
                    end
                otherwise                   
                    if isscalar(obj) 
                        out = obj.date;
                    else
                        out = cell2mat({obj(:).date}.');                
                    end
            end
        end
        
        function out = getSizes(obj,flag)
            % hsicube:getSizes This returns the size of the cube(s).
            if ~isa(obj,'hsicube')
                error('Input must be an hsicube object...');
            end
            if nargin < 2
                flag = 0;
            end
            if isscalar(obj) 
                out = obj.cubesize;
            else
                out = (cell2mat({obj(:).cubesize}.'));
            end
                
                    
        end
        
        function out = setWavelengths(obj, value)
            % hsicube:setWavelengths This allows for setting the
            % wavelengths of the cubes to a given array.
            out = [];
            szs = getSizes(obj);
            if any(szs(:,3) ~= length(value))
                error('Input doesnot match number of wavelengths of cube.')
            end
            
            if isscalar(obj)
                obj.wavelengths = value;
            else
                for ii=1:length(obj)
                    % Call it on each of the scalar objs:
                    obj(ii).wavelengths = value;                  
                end
            end
            out = 1;
        end
         % Loading the cubes.
        function out = loadCube(obj)
            % hsicube:loadCube This function loads and returns the full
            % cube. At the moment, this function only operates on SCALAR
            % hsicubes...
            if ~isa(obj,'hsicube')
                error('Input must be an hsicube object...');
            end
            if isscalar(obj)
                if ~isempty(obj.matdir)
                    if isempty(obj.wavelengths)
                        load(obj.matfilename,'A','t')
                        obj.wavelengths = t.wavelength;
                    else
                        load(obj.matfilename,'A')
                    end
                    out = A;
                    
                elseif ~isempty(obj.cubedir)
                    out = cuberead(cubefilename);
                else
                    error('Load directories not specified.')
                end
            else
                error('Input must be a SCALAR hsicube');
            end
        end
        
        function out = loadPanel(obj)
            % hsicube:loadCube This function loads and returns the panel
            % for a Denali data cube. At the moment, this function only 
            % operates on SCALAR hsicubes...
            if ~isa(obj,'hsicube')
                error('Input must be an hsicube object...');
            end
            if isscalar(obj)
                if ~isempty(obj.paneldir)
                    load(obj.panelfilename,'C')
                    out = C;
                else
                    warning('No panel available for this cube...')
                end
            else
                error('Input must be a SCALAR hsicube');
            end
        end
        
        function out = loadMaterials(obj,radius,medianflag,locperturb,oth_pts)
            % hsicube:loadCube This function loads and returns the 
            % materials on the panel of a Denali data cube. At the moment, 
            % this function only operates on SCALAR hsicubes...
            % 
            % Arguments: 
            %  radius  [ r ]    This gives a set radius around the set
            %                   sample points
            %          [ x y ]  This allows for varying radius in different
            %                   directions.
            %                   **radius < 0 makes it interactive: you pick
            %                   points on the panel which you would like to
            %                   sample, in addition to the 27 materials.
            %
            %  medianflag [t/f] Median filter the pixels? Default: T
            %
            %  locperturb [t/f] Use local perturbations to find a better
            %                   local alignment? Default: T
            %
		if ~isa(obj,'hsicube')
                error('Input must be an hsicube object...');
            end
			interactive = 0;
            if nargin > 1
                if isempty(radius)
                    hradius = 1;
                    vradius = 1;
                elseif length(radius) == 2 %&& ~isempty(radius)
					if any(radius <= 0)
						interactive = 1;
					end
                    hradius = abs(radius(1));
                    vradius = abs(radius(2));
                elseif length(radius) == 1  %&& ~isempty(radius)
					if radius <= 0
						interactive = 1;
					end
					hradius = abs(radius);
                    vradius = abs(radius);
                else
                    error('radius input wrongly...')
                end
                
            else
                hradius = 1;
                vradius = 1;
            end
            if nargin < 3
                medianflag = true;
            elseif isempty(medianflag)
                medianflag = true;
            else
                xx = (medianflag == [0 1]);
                assert(xor(xx(1),xx(2)),['Error in input: medianflag format']);
            end
            if nargin < 4
                locperturb = true;
            elseif isempty(locperturb) 
                locperturb = true; 
            else
                xx = (locperturb == [0 1]);
                assert(xor(xx(1),xx(2)),['Error in input: locperturb format']);
            end
            if nargin < 5
                in_pts = 0;
                oth_pts = [];
            else
                in_pts = 1;
                assert(size(oth_pts,2) == 2,[ 'The input points are not'...
                           ' in the correct format...']);
            end
            
            
            
            % These variables  are for future enhancements of this function:
            % In order to vary where the neighborhood is defined, the
            % possiblity to change that either for a specific row, or even
            % individually could be added using these offsets.
            hoffset = 0;
            voffset = 0;
            
            % If needed, each row of indexes for the Denali data is also
            % given:
            firstrow  = [  1     5     9    13    17    21 ];
            secondrow = [  2     6    10    14    18    22 ];
            thirdrow  = [  3     7    11    15    19    23    25 ];
            fourthrow = [  4     8    12    16    20    24    26    27 ];
            
            % The centroids of the majority of the panels for the Denali
            % data isgiven in the vaiable pts:
            pts = [ 32    29    31    23    30    17   ...
                    28    12    46    29    45    23   ...
                    44    17    43    12    59    29   ...
                    58    23    57    17    56    12   ...
                    73    29    72    23    71    17   ...
                    70    12    86    29    85    23   ...
                    84    17    83    12   100    29   ...
                    99    23    98    17    97    12   ...
                   112    17   111    12   125    12 ];
            pts = reshape(pts,2,[])';
            
            % Adding in pts that should be sampled in addition to the
            % materials...
            if in_pts
                
                pts = [pts; oth_pts];                
            end
            
            
			% Interactive part:
			if interactive 
				% Load up an image of of the panel..
				cbs = round(rand(1,min(3,length(obj)))*(length(obj)-1))+1;
                for ii = 1:length(cbs)
                    %Sc(:,:,:,ii) = makeBroadBandPicture(obj(cbs(ii)).loadPanel());
                    S = obj(cbs(ii)).loadPanel();
                    S = cat(3,rot90(mean(S(:,:,1:50),3)), rot90(mean(S(:,:,100:150),3)),...
                    rot90(mean(S(:,:,200:250),3)));
                    for iter = 1:3
                        S(:,:,iter) = S(:,:,iter) - min(min(S(:,:,iter)));
                        S(:,:,iter) = S(:,:,iter)./max(max(S(:,:,iter)));
                        S(:,:,iter) = adapthisteq(S(:,:,iter),'distribution','rayleigh');
                    end
                    Sc(:,:,:,ii) = S;
                end
                S = sum(Sc,4)./length(cbs);
                
        
                % Throw the cube up on the display...
                fh = figure;
                ah = axes;
                imagesc(1:150,1:40,S,'parent',ah);
                title('Select points and press enter...')
                % Pick some points to select (ginput)
                [newptsx newptsy bttns] = ginput;  % Bttns may be used later on...
                
                % Form the new pts to be added to the pts array...
                newpts = round([newptsx newptsy]);
                pts = [pts; newpts];
                
                % Close the figure that was opened...
                close(fh)
			end % interactive...
			
			
            %if isscalar(obj)
            if ~any(cellfun(@isempty,{obj.paneldir}))
                nFiles = length(obj);
                S = load(obj(1).panelfilename,'C');
                C = S.C;
                nwavelengths = size(C,3);
                if medianflag
                    numpixs = 0;
                    pixs = zeros(nFiles,size(pts,1),nwavelengths);
                else
                    numpixs = (hradius*2+1)*(vradius*2+1);
                    pixs = zeros(nFiles,size(pts,1),nwavelengths,numpixs);
                end
                for fiter = 1:nFiles
                    S = load(obj(fiter).panelfilename,'C');
                    C = S.C;
                    Csz = size(C);
                    if locperturb
                        obj(fiter).materialLocalOffsets = zeros(size(pts,1),2);
                    end
                    %%% Do some stuff....
                    for miter = 1:size(pts,1);  % Material iterator
                        
                        % Set up the horizontal and vertical indices
                        horz = pts(miter,1) + [-1*hradius:hradius] + hoffset;
                        vert = pts(miter,2) + [-1*vradius:vradius] + voffset;
                        
                        % If we are going to work with some local offsets:
                        if locperturb
                            % Ok, I neeed to define how much I am moving
                            % the centroid around...
                            lhoffset = [-1:2];
                            lvoffset = [-1:1];
                            
                            % Form them into a vector that sweeps over all
                            % possible combos of the above set center
                            % centroids.
                            h = kron(lhoffset.', ones(length(lvoffset),1));
                            v = kron(lvoffset.',ones(1,length(lhoffset))); v = v(:);
                            corrs = zeros(size(h));
                            
                            % This is to form a weighting on the shifts,
                            % to keep it close to (0,0)...
                            hv = [h v];
                            sig = [diag([6 3])];
                            %P1 = diag(det(sig)^(-1/2)*exp(-1/2*hv*inv(sig)*hv'));
                            
                            dd = sqrt(sum(hv.^2,2));
                            maxdd = max(ceil(dd))*2;
                            P3 = 1 - 10.^(-(maxdd-(round(dd*20)/10)));
                            
                            
                            % Sweep over all shifts.
                            for lpiter = 1:length(v)
                                % Add in local shift...
                                thorz = horz + h(lpiter);
                                tvert = vert + v(lpiter);
                                
                                % Guard against anything outsied the panel
                                % size:
                                thorz( thorz < 1 | thorz > Csz(1)) = [];
                                tvert( tvert < 1 | tvert > Csz(2)) = [];
                                if isempty(thorz) || isempty(tvert)
                                    continue
                                end
                                
                                % Grab the materials, forming them into a
                                % matrix...
                                ptmp = cube2matrix(C(thorz,tvert,:));                                 
                                % Calculate the cross correlation...
                                P = tril(ptmp.'*ptmp,-1);
                                P = bsxfun(@ldivide,sqrt(sum(ptmp.^2)).',bsxfun(@rdivide,P,sqrt(sum(ptmp.^2))));
                                % And sum it up...
                                %corrs2(lpiter) = sum(sum(abs(P)))./sum(1:(numel(horz)*numel(vert)-1))*P1(lpiter);
                                %corrs1(lpiter) = sum(sum(abs(P)))./sum(1:(numel(horz)*numel(vert)-1));
                                corrs(lpiter) = sum(sum(abs(P)))./sum(1:(numel(thorz)*numel(tvert)-1))*P3(lpiter);
                            end
                            
                            % Ok, now, let's find the largest correlation
                            [mx mxind] = max(corrs);
                            
                            % Ok, now update the horzontal and vertical
                            % offsets to use...
                            horz = horz + h(mxind);
                            vert = vert + v(mxind);                            
                            
                            % And we better save these somehow....
                            obj(fiter).materialLocalOffsets(miter,:) = [h(mxind) v(mxind)];
                        end
                        
                        % Guard against out-of-bounds errors:
                        horz( horz < 1 | horz > Csz(1)) = [];
                        vert( vert < 1 | vert > Csz(2)) = [];
                        
                        % Actually we don't need to worry, because indexing
                        % with an empty array is alright -- It doesn't grab
                        % anything out...
                        %if isempty(horz) || isempty(vert)
                        %    continue
                        %end
                        
                        if medianflag
                            %%% Neighborhood averaging
                            pixs(fiter, miter,:) = squeeze(median(median(C(horz,vert,:),2),1));
                        else
                            Csub = cube2matrix(C(horz,vert,:));
                            subnpixs = size(Csub,2);
                            pixs(fiter, miter,:,1:subnpixs) = reshape(Csub,1,1,nwavelengths,subnpixs);
                            pixs(fiter, miter,:,subnpixs+1:numpixs) = nan(1,1,nwavelengths,numpixs - subnpixs);
                        end
                    end % End for miter=1:size(pts,1)
                end % End for fiter=1:nFiles

                %inds = [  1 3:length(size(pixs))];
                out = pixs; %permute(pixs,inds);
            else
                warning('No panel available for one or more cubes...')
            end
            %else
            %    error('Input must be a SCALAR hsicube');
            %end
        end
    end % Methods
    
    methods (Static = true)
        % These are associated with the class, NOT the instances/objects of
        % the class.
        
        
        % Loading the cubes.
%         function out = loadCube(obj)
%             if ~isa(obj,'hsicube')
%                 error('Input must be an hsicube object...');
%             end
%             if isscalar(obj)
%                 if ~isempty(obj.matdir)
%                     load(obj.matfilename,'A')
%                     out = A;
%                 elseif ~isempty(obj.cubedir)
%                     out = cuberead(cubefilename);
%                 else
%                     error('Load directories not specified.')
%                 end
%             else
%                 error('Input must be a SCALAR hsicube');
%             end
%         end
%         
%         function out = loadPanel(obj)
%             if ~isa(obj,'hsicube')
%                 error('Input must be an hsicube object...');
%             end
%             if isscalar(obj)
%                 if ~isempty(obj.paneldir)
%                     load(obj.panelfilename,'C')
%                     out = C;
%                 else
%                     warning('No panel available for this cube...')
%                 end
%             else
%                 error('Input must be a SCALAR hsicube');
%             end
%         end
    end % Static Mehods
    
    
    
end % classdef hsi