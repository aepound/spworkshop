%{
\documentclass[10pt]{article}
\usepackage{standalone}

\usepackage{currfile}
\newcommand{\libdir}{./lib}
\input{\libdir/sarcommonheader}

\onehalfspacing

\title{Machine Learning on Sparse Decompositions of Hyperspectral
  Images} 

\author{Andrew Pound}
\date{\today}
%}
% Matlab code for running the experiments detailed in this paper.
clear all
close all

debugging = false;
%debugging = true;

% Matlab output directory.  The place to put the output files that we
% are making...
outdir = './matout';
%{
% Let's make it the same in LaTeX...
\newcommand{\matdir}{./matout}
%}
% Record version of MATLAB/Octave
a = ver('octave');
if length(a) == 0
    a = ver('matlab');
end
fid = fopen([outdir filesep 'vers.tex'], 'w');
fprintf(fid, [a.Name ' version ' a.Version]);
fclose(fid);

% Record computer architecture.
fid = fopen([outdir filesep 'computer.tex'], 'w');
fprintf(fid, ['\\verb+' computer '+']);
fclose(fid);

% Record date of run.
fid = fopen([outdir filesep 'date.tex'], 'w');
fprintf(fid, datestr(now, 'dd/mm/yyyy'));
fclose(fid);

% Add in the paths necessary for the HSI processing.
addpath(genpath('./matlab'));
\
%{
\begin{document}
\maketitle

%\begin{abstract}
%\end{abstract}

What am I doing for this paper? 
I am going to perform the comparison that should have been part of my
thesis.  I will first run a number of ML algorithms on the raw HSI
data itself to see how it is able to do at classifying the HSI
pixels. I hope that they are on par with the RF that I had in the
thesis. 

Then I plan on decomposing the data using a DL algorithm and then
seeing if the results of the thesis are still valid.

This document will be a Sweave/Matweave document.  I will be working
in both languages and hope to be able to code just about everything in
here, to be distributed as needed.  



\begin{matcode}
%}
%% Initialization/Preparation
[hntest host] = system('hostname');
host = host(1:end-1);
if ~hntest
    switch host
      case {'conan','lb-black'}
        addpath('/home/aepound/Dropbox/HSI/work')
        addpath('/home/aepound/Dropbox/HSI/work/scripts') % has the cubeinfo .mat
        addpath('/home/aepound/Dropbox/HSI/rf/try1')
        cd ~/Dropbox/HSI/work/
        load('acrosstimevars','allCubes','mats','wavelengths','t');
      otherwise
        load RFfails.mat
    end
end

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

nselect = 10;               % # of training cubes to select.

sameNumTest = 1;            % Do we want the same number of test
                            % samples as training samples?

votes = zeros(szmats(1),szmats(4));

mfh = 0;
plotting = 0;

for iter = 1:nmats
    % Grab this materials:
    data = cube2matrix(squeeze(mats(:,:,:,iter)));
    % Compute the histogram...
    [H d] = hist(data.', nhist);
    if plotting
        mfh(iter) = figure;
        imagesc(1:258,d,H),set(gca,'ydir','normal'),hold on
    end
    % Finding the most "used" spectra..
    [mx mxind] = max(H);
    px = d(mxind);
    if plotting
        plot(1:258,px,'k','linewidth',2)    
    end
    
    d2 = median(data,2);
    if plotting
        plot(1:258,d2,'k*-','linewidth',1.5)
    end
    
    Hnorm = (H./npixs);
    Hnorm1 = bsxfun(@rdivide,Hnorm,sqrt(sum(Hnorm.^2)));
    Hh = bsxfun(@times,d,Hnorm1.^2);
    dd = sum(Hh);
    if plotting
        plot(1:258,dd,'w','linewidth',2)
    end
    
    Hnorm1 = bsxfun(@rdivide,Hnorm.^2, sqrt(sum((Hnorm.^2).^2)));
    Hh = bsxfun(@times,d,Hnorm1.^2);
    dd = sum(Hh);
    if plotting
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

if ~sameNumTest
    selection = srtind(1:nselect+1);
    bestCubes = allCubes(selection);
    testCube = bestCubes(1);
    bestCubes = bestCubes(2:end);
else
    selection = srtind(1:nselect*2);
    bestCubes = allCubes(selection);
    testCube = bestCubes(1:2:end);
    bestCubes = bestCubes(2:2:end);
end





%{  
\end{matcode}






<<global_options, include=FALSE}>>=
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.path='Figs/',
                      echo=FALSE, warning=FALSE, message=FALSE)
@


\begin{matcode}
%}
% This will run this document through R, and then compile it in latex.
if ~debugging
fname = mfilename;
ext = '.Rnw';

if exist([fname ext],'file')
  delete([fname ext]);
end

[succ,msg,msgID] = copyfile([fname '.m'],[fname ext]);

% R command to run...

% LaTeX command
if isunix
  system(['pdflatex -interaction nonstopmode ' fname '.tex > /dev/null']
  system(['pdflatex -interaction nonstopmode ' fname '.tex > /dev/null']
else
  system(['pdflatex -interaction nonstopmode ' fname '.tex > trash']
  system(['pdflatex -interaction nonstopmode ' fname '.tex > trash']
end
end % if ~debugging...
%{  
\end{matcode}

% \bibliographystyle{ieeetr}
% \newcommand{\bibdir}{~}
% \bibliography{\bibdir/~}
\end{document}
%}