# MATLAB_DifferentialEvolution
Implements the basic functionality of Differential Evolution (Turner &amp; Sederberg, 2012) in the MATLAB language


## How to construct and fit a model.
In order to fit a model, you need to write a single script that runs with multiple functionalities. During initialization, you create a MODEL object, which can be given a name of your choosing. 

### 1. Create a new script
```
MODEL.file_new('myNewModel')
```
Inside of the new script you've created, there will be a handful of code, that runs some basic functions:
#### Create MODEL object
```
M = MODEL();
```
We need to associate some data with our model.
#### Example: load data from a .mat file in the same directory called "myData.mat"
```
load myData.mat
M.data = myData;
```

We need to define priors for our parameters in the model.
The Priors structure is a Px7 cell array, which will contain P rows, one for each parameter. 

- The 1st column needs to contain the name of a probability distribution, e.g. 'normal','uniform',etc. . .
- The 2nd and 3rd columns contain real-valued numbers which define the parameters for the distribution, e.g. mean and standard deviation
- The 4th and 5th columns allow for hierarchical structuring, and describe which **other parameters** should be used to parameterize the distribution
- The 6th and 7th columns describe transformations of hierarchical parameters, (if necessary) using ML anonymous functions
#### Example: We want to fit our data using a normal distribution with 2 parameters, a mean and standard deviation. Let the prior on the mean to be a Normal(0,10), and the prior for the standard deviation to be U(0.1,5)
```
M.bayes.priors(1,:) = {'normal',0,1};
M.bayes.priors(2,:) = {'unif',0.1,5};
```

### 2. Initialize the model
In the command line, create a handle to the model object we want to play with. In the following example, replace 'myNewModel' with the name of the script you have been editing.
```
M = myNewModel
```

### 3. Fit the model
Fitting is as easy as running the 'fit' method:
```
M.fit
```
