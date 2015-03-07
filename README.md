# Matlab + R + LaTeX = MatknitrTeX???

This is a paper that I'm writing for a signal processing conference.  
It invollves utilizing a number of machine learning algorithms on 
a lot of data that I've been working on in `Matlab`.  I have been 
writing most of my work up in a format where I can take advantage
of LaTeX and Matlab together (a la 
[MatWeave](http://staffwww.dcs.shef.ac.uk/people/N.Lawrence/matweave.html)).
But in order to conveniently use the power or R in the same format, 
I need to incorporate the R into my LaTeX document also.  This is 
my trial run to see if this is really feasible.


I am up in the air on how to actually do the compilation. I have 
2 methods, so far:
- makefile: This allows for partial compilation depending on whether it is needed.
- Matlab: matlab can run shell commands at the end of the script.

I will have to maybe try out both methods and see which fits my needs
better.

## General idea

I imagine the workflow would be something like this:
1. I run matlab on the foo.m file to produce the dataset(s) that I need.
2. I then cat the file into a foo.Rnw file and run R -e "knitr("foo.Rnw")", 
or something like that...
3. I then run Matlab (if there are any results that I need to analyze in 
Matlab more..)
4. Then I latex the output to produce the final document.

## Matlab portion

I use Matlab for most of my coding.  I am very familiar with it and have 
a lot of experience working in it.  I also have a lot of code that I'm 
leveraging from my thesis to be able to do the analysis more efficiently.
I am only barely proficient in R, so this will be an adventure. I have done
some machine learning in R, so as long as I am able to get the information 
I need back into matlab or the LaTeX, then I should be alright.

## Things to look into:

1. Does R have a `.mat` reader?  That would make transfer of variables 
much easier.
2. What ML algorithms do I want to look at?
 

