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
\usepackage[style=ieee]{biblatex}

\addbibresource{\refdir/references.bib}

% Title.
% ------
\title{Machine Learning on Hyperspectral Image Radiance Spectra} 

%
% Single address.
% ---------------
\name{A. E. Pound, T. K. Moon, J. H Gunther\thanks{Thanks to LLNL for
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
if isempty(a)
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
reprocess = false;
%% Initialization/Preparation
loadHSI
%{  
\end{matcode}


<<global_options, include=FALSE>>=
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.path='figs/',
                      echo=FALSE, warning=FALSE, message=FALSE)
debug.this.file = FALSE;
@


<<managing_packages, include=debug.this.file, echo=FALSE>>=
#$ Specify the data run.
data.run = 3

## Set up the directories...
repo.dir  <- getwd()
rcode.dir <- paste(repo.dir,'/R',sep='')
rout.dir  <- paste(repo.dir,'/Rout',sep='')

## Set up save file names
run.data.fname = paste(rout.dir, "/fullResults",
  formatC(data.run,format='d',flag='0'),
  ".Rdata",sep='')
if (!file.exists(run.data.fname)) {
 #  source('main.r')
 print('Going to run the whole shebang!')
}else {
  print('Algorithms already ran. Loading results...')
  load(run.data.fname)
}
@


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

HSI is used in many different fields, including 
forestry\autocites{Clark2005}{Govender2007}, 
geology\autocites{Resmini1997}{Sabins1999},
medicine\autocites{Freeman1997}{Li2013},
%\autocites{Martin2006}{Blanco2012}{Uhr2012}{Sorg2005}{Panasyuk2007}{Akbari2012},
manufacturing, and food quality.   

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
Linear Discriminant Analysis (LDA) aims to find a linear boundary
between the classes with a minimum amount of error.

\Textcite{Du2008} apply LDA to HSI data, and investigate the
effectiveness of pairing it with a dimensionality reducing
pre-processing step.

A regularized LDA is applied by \Textcite{Bandos2009} in the particularly
ill-posed problem of a small number of training samples and a large
number of spectral features.  They report success in utilizing the
regularized version of LDA and compare it to others that have used LDA
for HSI classification.

\subsection{Naive Bayes}
\label{sec:naive}

A Naive Bayes classifier considers each variable in the data vector to
be independent of the others\autocite{Murphy2012}.  It is because of
this assumption that 
it is considered naive.  A model is fit such that for a feature (data)
vector $\xbf \in \mathbb{R}^D$, 
\begin{equation}
  p(\xbf | y = c, \thetabf) = \prod_{j = 1}^Dp(x_j | y = c, \thetabf_{jc}.
\end{equation}



\subsection{Support Vector Machines}
\label{sec:svm}

Support Vector Machines (SVMs) are a classification technique that
ries to maximize the margin between classes\autocite{Moon2000}.  SVMs
find a linear separation between classes, although through the use of
the ``kernel trick.''  The trick is to utilize a kernelized inner
product to project the data into a different (often higher
dimensional) space where the classes may be linearly
separable\autocite{Murphy2012}. 

SVMs have been used to classify HSI pixels numerous times.  
\Textcite{Melgani2004} classify HSI pixels and compare the results
against a K-nearest neighbors and a radial basis function neural
network classifier.  
They also investigate using a 1 versus 1 and a 1
versus all frameworks for SVM multiclass performance.
\Textcite{Tarabalka2010} paired a SVM with a Markov Random Field (MRF)
in order to incorporate spatial information. 
They attributed their
gains to the spatial information incorporation. 


\subsection{CART}
\label{sec:cart}

Classifcation and Regression Trees (CART) proposed by
\textcite{Breiman1984} \citetitle{Breiman1984} are a binary tree-based
approach to find a classification criteria.  
At each node of the tree, a comparison is made on the value of a
particular variable.  
As the data is moved down the tree, a space is carved out of the
feature space that corresponds then to the assigned label or class and
any testing vectors that fall within this space are labeled as such.

\Textcite{GomezChova2003} determined that although the CART algorithm
did not perform extremely well as a classifier on HSI data, it did
perform well in feature/band selection as a form of dimensionality
reduction.  They demonstrated that utilizing CART in this fashion
improved classification performance.

\subsection{RandomForests}
\label{sec:rf}

\newcommand{\rf}{RandomForests}

\Textcite{Breiman2001} in \citetitle{Breiman2001} proposed using an
ensemble of classification 
trees to improve classification and regression results. 
Incorporating random decisions into the algorithm, Breiman named this
algorithm \rf{}.
The manner in which randomness was inserted into the learning of the
trees was first, by bagging (random selection of training samples) and
second, a random selection of the subset of the variables over which
the split could be made at each decision.

\rf{} has 
\Textcite{Ham2005} 

\Textcite{Joelsson2005}

\Textcite{Crawford2003}
%\Textcite{Abe2012}
%\Textcite{Du2012}


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

\section{Methods}
\label{sec:methods}

In order to test the various different methods against the test data,
a \Sexpr{fitControl$number}-factor crossvalidation was performed to
identify the best tuning parameters for the models.  A classifier was
then trained using the best tuning parameters found and the test set
was run through the resulting model.  The test set results are shown
in \cref{tab:results}.

\section{Results}
\label{sec:results}

<<post_processing, include=debug.this.file,echo=TRUE>>=
  source(paste(rcode.dir,'/postproc.r',sep=''))
  print('Done with post processing...')
  results = as.data.frame(sort(Errs))
  names(results) <- '% Error';
  results = t(results)*100
@


<<results_table, results="asis">>=
check_n_install_packages('xtable')
cent = do.call(paste,as.list(c(rep('c',length(results)+1),sep='')))
xtable(results,booktabs=TRUE,
  caption=paste('Error results from the test set using the ',
                'parameters learned from ',
                formatC(fitControl$number,format='d'),
                '-fold crosvalidation.',sep=''),
  label="tab:results",
  caption.placement='top',
  align=cent)  
#$
@



\section{Reproducible Research}
\label{sec:rr}


\section{Conclusion}
\label{sec:conclusion}



\printbibliography

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

system(['R -e "getwd();library(knitr); knit(''./' [fname ext] ''')"']);

%%TODO: figure out the knitr command...

% LaTeX command
if isunix
  system(['pdflatex -interaction nonstopmode ' fname '.tex > /dev/null']);
  system(['bibtex ' fname ' > /dev/null']);
  system(['pdflatex -interaction nonstopmode ' fname '.tex > /dev/null']);
else
  system(['pdflatex -interaction nonstopmode ' fname '.tex > trash']);
  system(['bibtex ' fname ' > /dev/null']);
  system(['pdflatex -interaction nonstopmode ' fname '.tex > trash']);
end
end % if ~debugging...
%{  
\end{matcode}

% \bibliographystyle{ieeetr}
% \newcommand{\bibdir}{~}
% \bibliography{\bibdir/~}
\end{document}
%}
