%{
% Template for ICASSP-2008 paper; to be used with:
%          spconf.sty  - ICASSP/ICIP LaTeX style file, and
%          IEEEbib.bst - IEEE bibliography style file.
% --------------------------------------------------------------------------
\documentclass[10pt]{article}
\usepackage{standalone}

% Directories
%------------
\newcommand{\libdir}{./lib}
\newcommand{\refdir}{./refs}

\usepackage{\libdir/spconf}
\usepackage{epsfig}
\usepackage{currfile}

\input{\libdir/sarcommonheader}

\onehalfspacing
\usepackage{microtype}
\usepackage[backend=biber]{biblatex}

\addbibresource{\refdir/references}

% Title.
% ------
\title{Machine Learning on Hyperspectral Image Radiance Spectra} 

%
% Single address.
% ---------------
\name{A. E. Pound, T. K Moon, J. H Gunther\thanks{Thanks to LLNL for
    providing the HSI data tha twas used in this study.}}
\address{Utah State University\\
         Electrical And Computer Engineering Department\\
         Logan, UT}
%
% For example:
% ------------
%\address{School\\
%	Department\\
%	Address}
%
% Two addresses (uncomment and modify for two-address case).
% ----------------------------------------------------------
%\twoauthors
%  {A. Author-one, B. Author-two\sthanks{Thanks to XYZ agency for funding.}}
%	{School A-B\\
%	Department A-B\\
%	Address A-B}
%  {C. Author-three, D. Author-four\sthanks{The fourth author performed the work
%	while at ...}}
%	{School C-D\\
%	Department C-D\\
%	Address C-D}
%

\begin{matcode}
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
\end{matcode}
% Let's make it the same in LaTeX...
\newcommand{\matdir}{./matout}
\begin{matcode}
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
\end{matcode}

\begin{document}

\maketitle
%\begin{abstract}
%\end{abstract}

\begin{octavec}
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
\end{octavec}


\begin{matcode}
%}
%% Initialization/Preparation
loadHSI
%{  
\end{matcode}

\begin{Rcode}
<<global_options, include=FALSE}>>=
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.path='Figs/',
                      echo=FALSE, warning=FALSE, message=FALSE)
@


<<managing_packages, include=FALSE}>>=
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.path='Figs/',
                      echo=FALSE, warning=FALSE, message=FALSE)
setwd('./R')
source('main.r')
@
\end{Rcode}

\begin{abstract}
  
\end{abstract}
%
\begin{keywords}
Hyperspectral Imaging, Remote Sensing, Machine Learning, Classification
\end{keywords}
%
\section{Introduction}
\label{sec:intro}

Hyperspectral Imaging (HSI) is a remote sensing technique which
records an image from a scene in a range of different frequencies.
The spacing between the different frquency bins is small enough to
warrant calling it a spectrum.  

HSI is used in many different fields, including forestry, geology,
medicine, manufacturing, and food quality.  

Because of its wide applicability in many different industries, it is
of interest to be able to reliably detect and classify different
materials in a given HSI scene.  



\section{Classification on HSI}% Prior art:
\label{sec:class}
Many varieties of classifiers have been applied to HSI data before.
They range from simple classifiers to complex multiple layered nueral
network classifiers.  The aim of each is to determine 

\subsection{Linear Discriminant Analysis}
\label{sec:lda}

Linear Discriminant Analysis aims to find a linear boundary between
the classes and gives the

\subsection{Naive Bayes}
\label{sec:naive}

\subsection{Support Vector Machines}
\label{sec:svm}

\subsection{CART}
\label{sec:cart}

Classifcation and Regression Trees (CART) are a binary tree-based
approach to find a classification criteria.  
At each node of the tree, a comparison is made on the value of a
particular variable.  
As the data is moved down the tree, a space is carved out of the
feature space that corresponds then to the assigned label or class and
any testing vectors that fall within this space are labeled as such.


\subsection{RandomForests}
\label{sec:rf}

RandomForests is an ensemble




\section{Denali Dataset}
\label{sec:denali}
The Denali dataset is produced from an experiment that was conducted
at Lawrence Livermore National Laboratories.  
In the experiment, a long wave infrared (LWIR) hyperspectral camera
captured a scene approximately every ten minutes over a span of a few
months.   
Within the scene was placed a panel with a variety of different
materials ranging from minerals to plastics to natural materials.   

Of the materials in the scene we include 27 in our study.


\subsection{Cleaning the data}
\label{sec:dataprep}

A particular 9-day period was selected that allowed extraction of the
materials from the panel with high fidelity.  
From this 9-day period, the center-most 9 pixels of each material were
collected.   

The pixels from each of the 936 cubes were then histogrammed to find
the most representative spectra for each material.  
This was found by taking the max in the rdaiance direction over every
wavelength.   
This we term the ``representative'' spectrum of the material over the
time preiod.   

Each cube was then ranked according to how well it matched the
``representative'' spectra of each material, and the best twenty cubes
were selected as the data for this survey.

Ten of the cubes were used as the training set and ten were used as
the testing set.  Thus, each set comprised of 2430 pixels (27
materials $\times$ 9 pixels $\times$ 10 cubes).

The spectra of the pixels are raw radiance ($\mu$ flicks) as measured
by the HSI camera. 

\section{Results}
\label{sec:results}

\section{Reproducible Research}
\label{sec:rr}


\section{Conclusion}
\label{sec:conclusion}




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

%%TODO: figure out the knitr command...

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
