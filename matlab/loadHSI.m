%% This script will load the HSI data set.
% This will find the data needed and load it into the Matlab works
% space.  
if ~exist('reprocess','var')
  reprocess = true;
end
datadir = ['.' filesep 'data'];
outputdir = ['.' filesep 'matout'];
testfilename  = [outputdir filesep 'test'];
trainfilename = [outputdir filesep 'train'];

dictLearn = true; % false; %
mode = 1; % The minimize 1-norm w/ 2-norm error constraint.
dicSz = [140 ];%, 200, 400, 500]; % Let's just choose one for now.
lams  = [0.01]; %, 0.005, 0.001]; % lambdas to loop over.

if dictLearn

    dltestfilename  = [outputdir filesep 'testdl'  num2str(dicSz(1))];
    dltrainfilename = [outputdir filesep 'traindl' num2str(dicSz(1))];
end

%%
if reprocess || ~exist(testfilename,'file') || ~exist(trainfilename,'file')
clearvars('-except','datadir','outputdir',...
          'testfilename','trainfilename',...
          'dltestfilename','dltrainfilename',...
          'mode','dicSz','lams','dictLearn',...
          'reprocess')


load([datadir filesep 'acrosstimevars.mat'],'allCubes','mats','wavelengths','t');

% Chop them down a bit:
allCubes = allCubes(200:end);
mats = mats(200:end,:,:,:);
mats = permute(mats, [1 4 3 2]);
t = allCubes.getDates;
tnum = datenum(t);


%% Dataset
% First let's build us a decent set of cubes to do the learning from.
% The idea of this is to take a look at a histogram of each material, then
% select the top cubes which give us the nominal or best 
szmats = size(mats);
nmats = szmats(4);
nhist = 100;
npixs = prod(szmats(1:2));
nmost2pick = 100;
ntraincubes = 10;
ntestcubes = 10;
setAsideBest = true;
nselect = ntraincubes + ntestcubes + setAsideBest;
showfigs = false;

votes = zeros(szmats(1),szmats(4));

mfh = 0;                           % Figure handles
for iter = 1:nmats
    % Grab this materials:
    data = cube2matrix(squeeze(mats(:,:,:,iter)));
    % Compute the histogram...
    [H d] = hist(data.', nhist);
    if showfigs
        mfh(iter) = figure;
        imagesc(1:258,d,H),set(gca,'ydir','normal'),hold on
    end
        
    % Finding the most "used" spectra..
    [mx mxind] = max(H);
    px = d(mxind);
    if showfigs
        plot(1:258,px,'k','linewidth',2)    
    end
    
    d2 = median(data,2);
    if showfigs
        plot(1:258,d2,'k*-','linewidth',1.5)
    end
    
    Hnorm = (H./npixs);
    Hnorm1 = bsxfun(@rdivide,Hnorm,sqrt(sum(Hnorm.^2)));
    Hh = bsxfun(@times,d,Hnorm1.^2);
    dd = sum(Hh);
    if showfigs
        plot(1:258,dd,'w','linewidth',2)
    end
    
    Hnorm1 = bsxfun(@rdivide,Hnorm.^2, sqrt(sum((Hnorm.^2).^2)));
    Hh = bsxfun(@times,d,Hnorm1.^2);
    dd = sum(Hh);
    if showfigs
        plot(1:258,dd,'w*-','linewidth',1.5)
    
    
        hl = legend('max','median','weighted','weighted^2');
        set(hl,'color',[204 204 204]./256)
    end
    
    winner = px;
    
    % Compute the distance btwn px and all the data:
    dis = winner.'*data;
    
    dism = matrix2cube(dis,[szmats(1:2) 1]);
    dism = sum(dism,2);
    [dism2 dismind]=sort(dism);
    votes(dismind,iter) = (1:szmats(1)).';    
end

[srt srtind] = sort(sum(votes,2));

selection = srtind(1:nselect);
bestCubes = allCubes(selection);

traininds = 2:2:length(bestCubes);
testinds  = (setAsideBest*2+1):2:length(bestCubes);

verCube    = bestCubes(setAsideBest);                % Best representation 
testCubes  = bestCubes(testinds);                     % Test set cubes
trainCubes = bestCubes(traininds);                   % Training set cubes
testCube   = testCubes(1);                           % First test cube


%% Prepping to export to R
% Ok, now we have our training and test sets, let's get them ready
% to output to R.

%try
    % Training data:
%    trainmats = trainCubes.loadMaterials;
    % Testing data:
%    testmats = testCubes.loadMaterials;
%catch ME
% Then most likely, this machine doesn't have the real data...
% So grab it from the loaded data.
trnmats = mats(selection(traininds),:,:,:);
tstmats = mats(selection(testinds), :,:,:);
trainmats = [];
for iter = 1:size(trnmats,1)
    trainmats = cat(1,trainmats, squeeze(trnmats(iter,:,:,:)));
end
trainmats = permute(trainmats,[1 3 2]);
testmats = [];
for iter = 1:size(tstmats,1)
    testmats = cat(1,testmats, squeeze(tstmats(iter,:,:,:)));
end
testmats = permute(testmats,[1 3 2]);
%end

sztrain = size(trainmats);
sztest = size(testmats);

mat2d_tr = cube2matrix(trainmats);
classes_tr = repmat(1:sztrain(2),sztrain(1),1);
classes_tr = (classes_tr(:)).';


mat2d_ts = cube2matrix(testmats);
classes_ts = repmat(1:sztest(2),sztest(1),1);
classes_ts = (classes_ts(:)).';


%% Output to R:
% These will output to the filenames given above...

% Write out the training data to the specified file.
if exist(trainfilename,'file')
    delete(trainfilename);
end
fid = fopen(trainfilename,'wt'); 
for iter = 1:size(mat2d_tr,2)
    fprintf(fid,'%g\t',mat2d_tr(:,iter));
    fprintf(fid,'%d\n',classes_tr(iter));
end
fclose(fid);

% Write out the testing data.
if exist(testfilename,'file')
    delete(testfilename);
end
fid = fopen(testfilename,'wt');
for iter = 1:size(mat2d_ts,2)
    fprintf(fid,'%g\t',mat2d_ts(:,iter));
    fprintf(fid,'%d\n',classes_ts(iter));
end
fclose(fid);

%%
if dictLearn
%% Dictionary Learning portion...
% The main idea of this portion is to learna dictionary and see if it
% classifies better on the abundances than on the raw data itself.  
% In some ways, this is a verification of my thesis, but also a broadening
% of the research to include more: my thesis only provided the comparison
% of RandomForests, whereas this allows for a much braoder comparison
% across many different classification algorithms.  
%
% It may also be of use to vary the parameters of the DL, to see if there
% would be benefits to a larger or a smaller dictionary, or different
% training parameters.

% Building the Dictionary 
% Ok, Now let's train up a dictionary for this:
opts = buildOptions;
opts.verbose = 1;

opts.K = dicSz(1);
opts.lambda = lams(1);
fprintf(1,'Sz: %d, lam: %g\n',opts.K, opts.lambda);

% Calculate the Dictionary:
[trainN trainfact] = spamsNormalize(mat2d_tr);            % normalize over all data...
%traint = bsxfun(@rdivide, train, sqrt(sum(train.^2)));  % normalize all to unit norm...
[~, Dt] = DictLearnFunc(trainN,opts,0);

% Do Sparse Coding on the training data...
[trainalpha] = SparseCoding(trainN,Dt,opts);

%%%=========================
% Now for the Test set:
% First, normalize by the same factor as the training set:
testN = mat2d_ts./trainfact;

% Do Sparse Coding on the training data...
[testalpha] = SparseCoding(testN,Dt,opts);

%%% Now let's write this out to file...
% Output to R:
% These will output to the filenames given above...

% Write out the training data to the specified file.
if exist(dltrainfilename,'file')
    delete(dltrainfilename);
end
fid = fopen(dltrainfilename,'wt'); 
for iter = 1:size(trainalpha,2)
    fprintf(fid,'%g\t',full(trainalpha(:,iter)));
    fprintf(fid,'%d\n',classes_tr(iter));
end
fclose(fid);

% Write out the testing data.
if exist(dltestfilename,'file')
    delete(dltestfilename);
end
fid = fopen(dltestfilename,'wt');
for iter = 1:size(testalpha,2)
    fprintf(fid,'%g\t',full(testalpha(:,iter)));
    fprintf(fid,'%d\n',classes_ts(iter));
end
fclose(fid);

    
%%
end

else % Not reprocessing the datasets
warning('NOT reprocessing the data from Matlab...');
end % If reprocessing...














