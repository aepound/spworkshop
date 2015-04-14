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

\section{Introduction}




\section{Hyperspectral Imaging}
Hyperspectral Imaging (HSI) is a remote sensing technique which
records an image from a scene in a range of different frequencies.
The spacing between the different frquency bins is small enough to
warrant calling it a spectrum.  

HSI is used in many different fields, including forestry, geology,
medicine, manufacturing, food quality

\section{Classification on HSI}% Prior art:
Many varieties of classifiers have been applied to HSI data before.

\subsection{Linear Discriminant Analysis}


\subsection{Naive Bayes}

\subsection{Support Vector Machines}

\subsection{CART}

\subsection{RandomForests}
RandomForests is an ensemble


\section{Methods Used}


\section{Results}


\section{Reproducible Research}


\section{Conclusion}




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
