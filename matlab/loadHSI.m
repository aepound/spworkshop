%% This script will load the HSI data set.
% This will find the data needed and load it into the Matlab works
% space.  
clear all

datadir = ['..' filesep 'data'];
outputdir = ['..' filesep 'matout'];
testfilename  = [outputdir filesep 'test'];
trainfilename = [outputdir filesep 'train'];

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

try
    % Training data:
    trainmats = trainCubes.loadMaterials;
    % Testing data:
    testmats = testCubes.loadMaterials;
catch ME
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
end

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
fid = fopen(trainfilename,'wt'); 
for iter = 1:size(mat2d_tr,2)
    fprintf(fid,'%g\t',mat2d_tr(:,iter));
    fprintf(fid,'%d\n',classes_tr(iter));
end
fclose(fid);

% Write out the testing data.
fid = fopen(testfilename,'wt');
for iter = 1:size(mat2d_ts,2)
    fprintf(fid,'%g\t',mat2d_ts(:,iter));
    fprintf(fid,'%d\n',classes_ts(iter));
end
fclose(fid);















