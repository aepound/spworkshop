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


<<global_options, include=FALSE}>>=
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.path='Figs/',
                      echo=FALSE, warning=FALSE, message=FALSE)
@


% \bibliographystyle{ieeetr}
% \newcommand{\bibdir}{~}
% \bibliography{\bibdir/~}
\end{document}
%}