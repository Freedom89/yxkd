---
title: Regression and it's relationship to Anova
date: 2021-07-02 0000:00:00 +0800
categories: [Knowledge, Statistics]
tags: [math]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Introduction

Over the years, I keep finding myself to revisit concepts of linear regression, and how it is related to other concepts within statistics, machine learning - which is primarily the reason why I started this site. The goal is to cover the following concepts:

* Regression formulation
* Derivation of solutions
* Variants of Regression / Model Selection methods 
* How is Regression related to Anova 
* Link to Logistic Regression

I assume knowledge of calculus and linear algebra at the undergraduate level.

## Regression 

The goal is to estimate a linear relationship between the target variable $Y$ with data/predictors $X$ and parameter $\beta_i$. 

$$
y_i = \beta_0 + \sum_{j=1}^K \beta_j x_{i,j} + \epsilon_i
$$

In Matrix Notation: 

$$
Y = X\beta + e
$$

Note, in matrix notation, $\beta_0$ is the intercept term with $x_{i,0}$ equals to some constant. To illustrate: 

$$
\begin{bmatrix}
y_1 \\ y_2 \\ \vdots \\ \vdots \\ y_n
\end{bmatrix}_{n\times 1} = 
\begin{bmatrix}
x_{1,0} =1 & x_{1,1} & x_{1,2} & \dots &x_{1,k} \\
x_{2,0}=1 & x_{2,1} & x_{2,2} & \dots &x_{2,k} \\
\vdots & \vdots& \vdots &\dots & \vdots\\
\vdots & \vdots& \vdots & \dots & \vdots\\
x_{n,0} =1 & x_{n,1} & x_{n,2} & \dots &x_{n,k} \\
\end{bmatrix}_{(n\times k)+1} 
\begin{bmatrix}
\beta_0 \\ \beta_1 \\ \vdots \\ \vdots \\ \beta_k
\end{bmatrix}_{(k+1) \times 1} + 
\begin{bmatrix}
\epsilon_1 \\ \epsilon_2 \\ \vdots \\ \vdots \\ \epsilon_n
\end{bmatrix}_{n \times 1} 
$$

## Assumptions

1. Linear Function - The mean response $E(Y_i )$ at each set of the predictors is a linear function. 
2. Independent - The errors $\epsilon_i$ are independent 
3. Normally distributed - The errors $\epsilon_i$ at each set of values of predictors are normally distributed. 
4. Equal Variances ($\sigma^2$) - Also known as Homoscedasticity : The errors $\epsilon_i$ at each set of values of predictors have equal variances. 

In other words,

$$
e \sim N(0, \sigma^2I)
$$

## Problem Formulation
 
We want to find parameters $\hat{\beta}$ to minimize the mean squared error (MSE) denoted as follows:

$$
\begin{aligned}
MSE &= \frac{1}{N}\sum_{i}^N (y_i - \hat{y}_i)^2 = \frac{1}{N} \sum_i^N \epsilon_i^2 \\
 &= \sum_i^N (y_i - (X_i\hat{\beta}))^2 \\
 &= \sum_i^N (y_i - (\hat{\beta_0}+\sum_{j=1}^K \hat{\beta_j}x_{i,j}))
\end{aligned}
$$

where:

* $\hat{y}$ denotes the model prediction
* $x_{i,j}$ denotes the i data point with j predictor. (i-row, j-column)
* $\epsilon_i$ denotes the residual $y_i - \hat{y}_i$
* Total of $N$ data points, with $K$ predictors. Note, in the case where $j$ starts from $0$,then $\beta_0$ is removed and instead $x_{0i}$ is simply 1 or some constant to represent the intercept term. 

In Matrix Notation,we denote $e = y-X\hat{\beta}$, then the mean squared error would be defined as:

$$
\begin{aligned}
e'e &= (Y-X\hat{\beta})'(Y-X\hat{\beta}) \\
&= Y'Y - \hat{\beta}X'Y - Y'X\hat{\beta}+ \hat{\beta}X'X\hat{\beta} \\
&= Y'Y - 2\hat{\beta}X'Y + \hat{\beta}X'X\hat{\beta}
\end{aligned}
$$

The notation $e'$ represents transpose, $e^T$ is sometimes used instead. 

Note, depending on journals and books:

* **error** is the difference between the observed value and the true value, this is usually unknown. 
* **residual** is the difference between the observed value and the predicted value by the model. Sometimes we represent this with $\hat{e_i}$. 
  
## Solving

Here are the various ways to solve to get $\hat\beta$. Here are a few:

* Ordinary Least Squares Method (OLE)
* Maximum Likelihood Estimation Method (MLE)
* Gradient Descent Method

## OLE

Given:

$$
e'e = Y'Y - 2\hat{\beta}X'Y + \hat{\beta}X'X\hat{\beta}
$$

To minimize, we need to find first derivative. 

$$
\frac{de'e}{d\hat{\beta}} = -2X'Y + 2X'X\hat{\beta}   
$$

Set derivative to be equals to 0,

$$
\begin{aligned}
-2X'Y + 2X'X\hat{\beta} &=0  \\
X'X\hat{\beta} &= X'Y
\end{aligned}
$$

If the inverse $(X'X)^{-1}$ exist, then:

$$
\begin{aligned}
(X'X)^{-1}X'X\hat{\beta} &= (X'X)^{-1}X'Y \\
I\hat{\beta}&= (X'X)^{-1}X'Y\\
\hat{\beta}&= (X'X)^{-1}X'Y
\end{aligned}
$$

To prove that this is indeed the minimum, we find the second derivative and prove that it is always greater than 0. 

$$
\frac{d^2e'e}{d^2\hat{\beta}} =  2X'X
$$

Under certain conditions, $X'X$ is positive definite. hence for all values of $\hat\beta$, the second derivative is always greater than 0. This proofs that it is the minimum. 

### Extra Matrix Info 

Note, earlier we made some assumptions, to address them:

*  If all predictors are independent and $n>k$, then $X$ must have full rank. 
      * This might not always be true in practice, e.g if $n<k$ i.e there are more features than data points, OR:
      * some features are a linear combination of other features.
      * usually not a problem and there are tricks to overcome it (feature selection, sampling, using gradient solvers etc)
*  A matrix is invertible if and only if it is full rank. 
*  This implies that $X^TX$ is positive definite. (which states that for any matrix A, A is positive definite if $x^TAx >0 \forall x\in\mathbb{R}$)

### Variance of Coefficients

The variance-covariance matrix for $\beta$ is defined as:

$$
var(\hat{\beta}) = \sigma^2 (X'X)^{-1}
$$

and $\sigma^2$ is estimated from $\hat{\sigma}^2$:

$$
\hat{\sigma}^2 = \frac{e'e}{n-k}
$$

[Full Proof Notes](https://web.stanford.edu/~mrosenfe/soc_meth_proj3/matrix_OLS_NYU_notes.pdf)

> **Further details on MSE vs variance**
>    
>    [Math Stack Exchange - What is the Difference between Variance and MSE?](https://math.stackexchange.com/questions/1357738/what-is-the-difference-between-variance-and-mse)
>
>    [Stats Exchange - What's the difference between the variance and the mean squared error?](https://stats.stackexchange.com/questions/140536/whats-the-difference-between-the-variance-and-the-mean-squared-error/140541)
>    
>    TLDR - If you recall sample variance, there is a sample correction where we divide by $n-1$. This is also known as the unbias estimator for population variance.
>    
>    Similarly, in the linear regression case, we are taking the distance from the regression line to the data point, and divide by the degree correction based on the number of parameters. 
{: .prompt-info }

### Proof of variance

First, Recall that $var(AX) = A(var(x))A^T$.
 
> **Prove that $var(AX) = A(var(x))A^T$."**
>    Note that: 
>
>    * $X \in \mathbb{R}$ is a random column vector 
>    * $Var(X) = E[(X-E[X])^2]$ which is equals to $E((X-E[X])(X-E[X])^T)$. This is also known as the variance-covariance matrix and is a constant matrix. 
>    * $A \in \mathbb{R}$ is a constant matrix 
>    * and so $var(AX)$ is a constant matrix
>    * $(AB)^T = B^TA^T$
>
>    $$
>    \begin{aligned}
>    var(AX) &= E((A(X-\mu))(A(X-\mu))^T) \\
>    &= E(A(X-\mu)(X-\mu))^T A^T) \\
>    &= A E((X-\mu)(X-\mu)^T)A^T \\
>    &= A(var(x))A^T
>    \end{aligned}
>    $$
>
>    Source: [Math stack exchange - What is the variance of a constant matrix times a random vector ](https://math.stackexchange.com/questions/2365166/what-is-the-variance-of-a-constant-matrix-times-a-random-vector)
>
>    For further details:
>
>    * [Math Stack exchange - Variance of coefficients in a Simple Linear Regression](https://math.stackexchange.com/questions/687310/variance-of-coefficients-in-a-simple-linear-regression)
>    * [Stanford notes - proof of variance in multi linear regression, page5 ](https://web.stanford.edu/~mrosenfe/soc_meth_proj3/matrix_OLS_NYU_notes.pdf)
>    * [Stats Stack exchange - How are the standard errors of coefficients calculated in a regression](https://stats.stackexchange.com/questions/44838/how-are-the-standard-errors-of-coefficients-calculated-in-a-regression/44841#44841)
>    * [Stats Stack Exchange - Derive Variance of regression coefficient in simple linear regression](https://stats.stackexchange.com/questions/88461/derive-variance-of-regression-coefficient-in-simple-linear-regression)
{: .prompt-info }

We start with the following equation and define matrix $A$:

$$
\hat{\beta} = \underbrace{(X'X)^{-1}X'}_{A}Y = AY
$$

$$
\begin{aligned}
A' &= ((X'X)^{-1}X')' \\
&= X(X'X)^{-1}
\end{aligned}
$$

This implies that:

$$
\begin{aligned}
var(\hat\beta) &= A \underbrace{var(Y)}_{\text{popn } \sigma^2}A' \\
&= (X'X)^{-1}X' \sigma^2 I X (X'X)^{-1}\\
&= \sigma^2 (X'X)^{-1}X'X(X'X)^{-1}\\
&= \sigma^2(X'X)^{-1}I
\end{aligned}
$$

and $\sigma^2$ is estimated with $\hat\sigma = \frac{e'e}{n-k}$.  


## MLE 

Another method or thought process to arrive at the same formulation is by making use of the assumption that residuals are normally distributed, independent with mean 0 and constant variance. This implies that:

$$
e \sim N(0,\sigma^2 I)
$$

The normal density function for the errors is:

$$
f(\varepsilon_i) = \frac{1}{\sigma\sqrt{2\pi}} exp \bigg[ - \frac{1}{2\sigma^2 } \varepsilon_i^2\bigg]
$$

Since:

* $\varepsilon_i$ is a function of $\beta,\sigma^2$ 
    * Think of it as each error depends on the value of $\beta$ and variance. 
* each $\varepsilon_i$ is independent, then the joint probability is the product:

$$
\begin{aligned}
L(\beta,\sigma^2) &= \prod_i^N f(\varepsilon_i) \\
&= \bigg[ \frac{1}{\sqrt{2\pi\sigma^2}}\bigg]^N \bigg[\prod_i^N exp \bigg[ - \frac{1}{2\sigma^2 } \varepsilon_i^2 \bigg]\bigg] \\
&= \bigg[ \frac{1}{\sqrt{2\pi\sigma^2}}\bigg]^N \bigg[exp \bigg[ - \frac{1}{2\sigma^2 } e'e \bigg]\bigg]
\end{aligned}
$$

Since to maximize the MLE is the same as maximizing the log likelihood since it is a monotonic increasing function, then:

$$
log L(\beta,\sigma^2) = - \frac{N}{2}log(2\pi\sigma^2) - \frac{1}{2\sigma^2} e'e
$$

To find $\hat\beta$ we take the first derivative:

$$
\frac{d log L(\beta,\sigma^2)}{d\beta} =  C \times e'e \text{ for some constant C}
$$

This is exactly the same equation as the OLS method, thus:

$$
\hat\beta = (X'X)^{-1}X'Y
$$

## Gradient Descent

There is another way of solving the values of $\beta$, via gradient descent. This is the algorithm: 

Denote the cost function to be $J$ and the predict function to be $h_\beta$: 

$$
J(\beta_0,...,\beta_K) = \frac{1}{2N} \sum_i^N (h_\beta(x_i) - y_i)^2
$$

The additional 1/2 in the cost function to make the derivation easier, but there is no actual impact if you exclude it.

$$
\begin{aligned}
\frac{dJ}{d\beta_j} &= \frac{d}{d\beta_j} \frac{1}{2N} \sum_i^N (\beta_0x_{i,0}+ ... + \beta_jx_{i,j}+...+ \beta_kx_{i,k} -y_i)^2 \\
&= \frac{1}{N} \sum_i^N (h_\beta(x_i)-y_i) \cdot x_{i,j}
\end{aligned}
$$

$x_{i,j}$ denotes $i$ data point at $j$ predictor, i.e the $(i,j)$ value in the dataset. 

Here is the full procedure, 

**Simultaneously** update $\beta_j$ until convergence with learning rate $\alpha$:

$$
\beta_j := \beta_j - \alpha \frac{1}{N} \sum_i^N (h_\beta(x_i)-y_i) \cdot x_{i,j}
$$

## SLR

In the case of simple linear regression, then:

$$
\hat{\beta_1} = \frac{\sum(x_i-\bar{x})(y_i-\bar{y})}{\sum(x_i-\bar{x})^2}, \hat{\beta_0}=\bar{y} - \hat{\beta_1}\bar{x}
$$

## Relation to correlation

Perhaps one way to better understand $\beta$ is to see how it is related to correlation $\rho$ in simple linear regression. To explain this, we need to look at coefficient of determination

## Coefficient of determination 

The coefficient of determination measures the percentage of variability within the values that can be explained by the regression model. For example $R^2$ x 100 percent of the variation in y is explained by the variation in predictor x. 

SST is the maximum sum of squares of errors for the data.

$$ \underbrace{\sum (y_i-\bar{y})^2}_{SST} = \underbrace{\sum(\hat{y_i}-\bar{y})^2}_{SSR}+\underbrace{\sum (y_i-\hat{y_i})^2}_{SSE}$$

* SST: Total variability in the y value (total sum of squares)
* SSR: Variability explained by the model (Regression sum of squares)
* SSE: Unexplained Variability (Error sum of squares)

$$R^2 = \frac{SSR}{SST} = \frac{\text{Variability explained by the model}}{\text{Total variability in the y value }}$$

[Extra Notes on why this relationship is true](https://stats.stackexchange.com/questions/207841/why-is-sst-sse-ssr-one-variable-linear-regression)

### (Person) Correlation Coefficient, $r$

The correlation coefficient, $r$, is directly related to the coefficient of determination $R^2$. If $R^2$ is represented in decimal form, then the correlation is the sqaure root. The sign will follow the sign of the slope coefficient $b_1$. 

$$
r = \pm \sqrt{R^2}
$$

$$
\begin{aligned}
r &= \frac{\sum (x_i - \bar{x})(y_i-\bar{y})}{\sqrt{\sum (x_i -\bar{x})^2}\sqrt{\sum (y_i -\bar{y})^2}} \\
&= \frac{\sqrt{\sum (x_i-\bar{x})^2}}{\sqrt{\sum (y_i-\bar{y})^2}} \beta_1
\end{aligned}
$$

This shows that the coefficient of determination of a simple linear regression is the square of the sample correlation coefficient of $(x_1,y_1),...,(x_n,y_n)$.

> **Proof"**
>
>    Denote $\hat{y}_i = \hat{\alpha} + \hat{\beta} x_i$ where $\hat{\alpha}$ and $\hat{\beta}$ are the ordinary least square estimators, and:
>
>    $$
>    \begin{aligned}
>    \hat{\beta} &= \frac{\sum(x_i-\bar{x})(y_i-\bar{y})}{\sum(x_i-\bar{x})^2}  \\
>    \\
>    \hat{\alpha} &= \bar{y} - \hat{\beta}\bar{x}\\
>    \\
>    \sum_{i=1}^n(\hat y_i-\bar y)^2
>    &=\sum_{i=1}^n(\hat\alpha+\hat\beta x_i-\bar y)^2\\
>    &=\sum_{i=1}^n(\bar y-\hat\beta\bar x+\hat\beta x_i-\bar y)^2\\
>    &=\hat\beta^2\sum_{i=1}^n(x_i-\bar x)^2\\
>    &=\frac{[\sum_{i=1}^n(x_i-\bar x)(y_i-\bar y)]^2\sum_{i=1}^n(x_i-\bar x)^2}{[\sum_{i=1}^n(x_i-\bar x)^2]^2}\\
>    &=\frac{[\sum_{i=1}^n(x_i-\bar x)(y_i-\bar y)]^2}{\sum_{i=1}^n(x_i-\bar x)^2}\\
>    \\
>    r^2 &=\frac{\sum_{i=1}^n(\hat y_i-\bar y)^2}{\sum_{i=1}^n(y_i-\bar y)^2}\\
>    &=\frac{[\sum_{i=1}^n(x_i-\bar x)(y_i-\bar y)]^2}{\sum_{i=1}^n(x_i-\bar x)^2\sum_{i=1}^n(y_i-\bar y)^2}\\
>    &=\biggl(\frac{\sum_{i=1}^n(x_i-\bar x)(y_i-\bar y)}{\sqrt{\sum_{i=1}^n(x_i-\bar x)^2\sum_{i=1}^n(y_i-\bar y)^2}}\biggr)^2
>    \end{aligned}
>    $$
{: .prompt-info }


# Is the Model useful?

In multiple linear regression, a reasonable question to ask is:

> Does the regression model contain at least one predictor that is useful? 
{: .prompt-info }

There are three possible hypothesis testing that are possible,

* **All** $\beta$ are zero
* A **subset** of the slope parameters is zero
* *one* slope parameter is zero 

There are others concepts such as sequential sum of squares, or interaction effects, which will not be covered here. IF you are interested:

* [1-way anvoa from scratch](https://towardsdatascience.com/1-way-anova-from-scratch-dissecting-the-anova-table-with-a-worked-example-170f4f2e58ad)
* [Anova three types of estimating sum of squares](https://towardsdatascience.com/anovas-three-types-of-estimating-sums-of-squares-don-t-make-the-wrong-choice-91107c77a27a)

For the next section,we will talk about anova for the hypothesis $\beta_i = \beta_j =0$.


## Anova table

> ANOVA stands for ‘Analysis of variance’ as it uses the ratio of between group variation to within group variation, when deciding if there is a statistically significant difference between the groups. Within group variation measures how much the individuals vary from their group mean. Each difference between an individual and their group mean is called a residual. These residuals are squared and added together to give the sum of the squared residuals or the within group sum of squares SSW. Between group variation measures how much the group means vary from the overall mean SSB.
{: .prompt-info }

Let's take a look at the Anova table:

| Source                         | Df    | SS                                           | MS                      | F                 | P-value |
| :----------------------------- | :---- | :------------------------------------------- | :---------------------- | :---------------- | :------ |
| Regression / Between Groups    | $k-1$ | SSR = $\sum_{i=1}^n (\hat{y}_i - \bar{y})^2$ | $MSR = \frac{SSR}{k-1}$ | $\frac{MSR}{MSE}$ |         |
| Residual Error / Within Groups | $n-k$ | SSE = $\sum_{i=1}^n (y_i - \hat{y}_i)^2$     | $MSE = \frac{SSE}{n-k}$ |                   |         |
| Total                          | $n-1$ | SSTO = $\sum_{i=1}^n (y_i - \bar{y})^2$      |                         |                   |         |

The F-statistics with $H_0 : \beta_i =\beta_j = 0$, and $H_a: \beta_i \neq 0$

$$
F^* = \frac{MSR}{MSE}, df =(k-1,n-k)
$$

The F-Test of overall significance in regression is a test of whether or not your linear regression model provides a better fit to a dataset than a model with no predictor variables.

### Fisher's LSD tests

The Fishers LSD test is basically a set of individual t tests. It is only used as a followup to ANOVA.

## Model Selection

In this section we talk about how to select a subset of predictors. Denote $L(\hat\beta)$ as the likelihood function for the model. This is related to stepwise selection, where we take each set of predictors and evaluate which gives a better information criterion and proceed iteratively. 

The next two sections on talks about information criterion, namely AIC and BIC: 

### AIC

Stands for Akaike information criterion and choose the best model with the **lowest** AIC:

$$
AIC = -2 log L(\hat\beta) + 2k
$$

where k is the number of parameters. 

The equation means that we must improve the log-likelihood for every one unit of extra parameter. It is asymptotically equivalent to leave-one-out cross validation. 

### BIC

Stands for Bayes information criterion, which penalizes complex model more severely. Similarly lowest BIC is taken to identify the "best" model. 

$$
BIC = -2 log L(\hat\beta) + p \times log(N)
$$

### Cross Validation

The other method is to do cross validation, such as leave one out, k-fold, etc. 

### Regularization

This is sort of related to model selection in a way, since we use these methods for feature selection / prevent over fitting. 

### L1 (Lasso)

Lasso regression is a type of linear regression that uses shrinkage. The acronym “LASSO” stands for Least Absolute Shrinkage and Selection Operator.

The cost function is: 

$$
Cost = \sum_i^N (y_i - \hat{y}_i)^2 + \lambda \sum_j^K |\beta_j|
$$

(Note that $\|x\|$ is not Differentiable at x=0)

This is why in L1 regression, if $\lambda$ is sufficiently large, some of the coefficients will shrink to $0$ due to the absolute value. (e.g it always reduces by that amount as compared to ridge regression!)

### L2 (Ridge)

Ridge Regression is a technique for analyzing multiple regression data that suffer from multicollinearity. This basically allows you to always make your matrix invertible - since it adds the identity matrix.

$$
Cost = \sum_i^N (y_i-\hat{y}_i)^2  + \lambda \sum_j^K \beta_j^2
$$

There is also a closed form matrix solution: 

$$
\hat\beta = (X^TX+\lambda I)^{-1}X^TY
$$

### Elastic Net

A combination of L1 and L2:

$$
Cost = \sum_i^N (y_i-\hat{y}_i)^2  +\lambda_1 \sum_j^K |\beta_j|+ \lambda_2 \sum_j^K \beta_j^2
$$


## GLM

Generalizing the linear regression model gives generalized linear model (GLM), where each outcome $Y$ to be related to the response variable via a link function. The linear regression is also known as the identity link. 

The family of link functions can be found in [wikipedia - GLM](https://en.wikipedia.org/wiki/Generalized_linear_model)

We use logistic regression as a motivating example. The link function $g$ is defined by:

$$
\begin{aligned}
E(Y) &= \mu = g^{-1}(X\beta) \\
\therefore g(\mu) &= X\beta
\end{aligned}
$$

### Logistic Regression 

Recall in logistic regression we are predicting binary class, ${1,0}$. 

The logit link function is:

$$
\begin{aligned}
g(\mu) &= \log( \frac{\mu}{1-\mu}) = X\beta \\
\mu &= \frac{e^{X\beta}}{1+e^{X\beta}} \\
&=  \frac{e^{X\beta}}{1+e^{X\beta}} \cdot \frac{e^{-X\beta}}{e^{-X\beta}} \\
&= \frac{1}{1+e^{-X\beta}} \\
\end{aligned}
$$

This looks exactly like the sigmoid function which outputs a number between ${0,1}$ - like a probability! Recall: 

$$
\sigma(x) = \frac{1}{1+e^{-x}}
$$

If we tried to calculate the cost function, we will arrive at a non-convex function with many local minimums. So we need to introduce a new cost function, which is known as sigmoid cross entropy loss. 

[Introduction to logistic regression](https://towardsdatascience.com/introduction-to-logistic-regression-66248243c148)


## Sigmoid Derivative

The sigmoid derivative is given by: 

$$
\sigma'(x) = \sigma(x)(1-\sigma(x))
$$

Given a function linear $z = X \beta$, then 

$$
\begin{aligned}
 \sigma(z)  &= h_\beta(x)\\
\sigma'(z) &= \frac{\delta}{\delta x} z\cdot \sigma(z) \cdot (1-\sigma(z))\\ 
\end{aligned}
$$

The proof is omiitted. 

## Cross Entropy 

Lets re-define $\sigma(z) = h_\beta(x) = \frac{1}{1+e^{-X\beta}}$ with the following cost function:

$$
Cost(h_\beta(x),y) = 
\begin{cases}
-log(h_\beta(x)),  & \text{if y = 1} \\
-log(1-h_\beta(x)), & \text{if y = 0}
\end{cases}
$$

Interpretation: 

| $X\beta$ | $h_\beta(x)$ | $y$  | Cost |
| :------- | :----------- | :--- | :--- |
| huge +ve | $\approx 1 - \varepsilon$  | 1    | $-log(1-\varepsilon)$     |
| huge +ve | $\approx 1 - \varepsilon$  | 0    | $-log(\varepsilon)$    |
| huge -ve | $\approx \varepsilon$  | 1    | $-log(\varepsilon)$    |
| huge -ve | $\approx \varepsilon$  | 0    | $-log(1-\varepsilon)$    |

Suppose $\varepsilon$ is small, then $log(\varepsilon)$ can be huge! 

For example, $X\beta$ outputs a huge negative value and hence the output prediction $h_\beta(x)$ is $0.00001$ which implies that $\hat{y} = 0$. However if in reality it is $1$, then the cost is equals to $-log 0.00001 = 11.51$!

With this, we can formalize our new cost function:

$$
\begin{aligned}
J(\beta) &= -\frac{1}{N}\sum_i^N [y_i log(h_\beta(x_i)) + (1-y_i)log(1-h_\beta(x_i))]\\
&= -\frac{1}{N}\sum_i^N [y_i log(\sigma(z)) + (1-y_i)log(1-\sigma(z))]
\end{aligned}
$$

## Gradient Descent

Finding a solution to logistic regression starts from the likelihood function, and there is no **analytical** solution - instead, gradient descent is used. To find the derivative, 

$$
\begin{aligned}
\frac{dJ}{d\beta_j} &= -\frac{1}{N} \sum_i^N \bigg[y_i \cdot \frac{1}{\sigma(z)} \cdot \frac{\delta}{\delta\beta_j} (\sigma(z)) \\
&+ (1-y_i) \cdot \frac{1}{1-\sigma(z)} \cdot \frac{\delta}{\delta\beta_j} (1-\sigma(z))\bigg] \\
&= -\frac{1}{N} \sum_i^N \bigg[y_i \cdot \frac{1}{\sigma(z)} \cdot \sigma(z)(1-\sigma(z)) \cdot \frac{\delta}{\delta\beta_j} (\beta^Tx_i) \\
&+ (1-y_i) \cdot \frac{1}{1-\sigma(z)} \cdot -\sigma(z)(1-\sigma(z)) \cdot \frac{\delta}{\delta\beta_j} (\beta^T x_i)\bigg] \\
&= -\frac{1}{N} \sum_i^N \bigg[ y_i \cdot (1-\sigma(z)) \cdot x_{i,j} + (1-y_i) \cdot -\sigma(z)\cdot x_{i,j}\bigg] \\
&= -\frac{1}{N} \sum_i^n x_{i,j} \bigg[ y_i . (1-\sigma(z)) - (1-y_i)\cdot\sigma(z) \bigg] \\
&= -\frac{1}{N} \sum_i^n x_{i,j} \bigg[ y_i - y_i \cdot \sigma(z) - \sigma(z) + y_i \cdot \sigma(z) \bigg]\\
&= -\frac{1}{N} \sum_i^n x_{i,j} \bigg[ y_i - \sigma(z) \bigg]\\
&= \frac{1}{N} \sum_i^N [\sigma(z)-y_i] x_{i,j}\\
&= \frac{1}{N} \sum_i^N [h_\beta(x_i)-y_i] x_{i,j}
\end{aligned}
$$

The gradient descent algorithm is as follows: 

$$
\beta_j := \beta_j - \alpha \frac{1}{N} \sum_i^N [h_\beta(x_i)-y_i] x_{i,j}
$$


Surprisingly, the update rule is the same as the one derived by using the sum of the squared errors in linear regression. As a result, we can use the same gradient descent formula for logistic regression as well.



## Other/Future notes

These are also useful concepts closely related to regression which are not covered here: 

* Different types of Anova
    * Two way Anova,
    * Multivariate Anova,
    * Ancova,
*  Model diagnosis
    * Lack of fit 
    * Order (Where the order of data matters) 
* Bias variance trade off
* Confidence Interval 
* Prediction Interval
* Higher order Interactions
* Degree of freedoms
* Dealing with troublesome features 
    * uncorrelated 
    * multi correlated 
    * High dimension  
    * Categorical Features
* Relation to time series 
* Linear mixed models
* Bayesian linear model 
  
## References 

[PennState - STAT 501; Regression methods](https://online.stat.psu.edu/stat501/)

[Towards Data Science - Linear Regression](https://towardsdatascience.com/linear-regression-91eeae7d6a2e)


[Stanford OLS notes - might be gone in the future](https://web.stanford.edu/~mrosenfe/soc_meth_proj3/matrix_OLS_NYU_notes.pdf)

[Scribber - one way anova](https://www.scribbr.com/statistics/one-way-anova/)

[Scribber - multiple linear regression](https://www.scribbr.com/statistics/multiple-linear-regression/)

[Medium - Derivative of log loss for logistic regression](https://medium.com/analytics-vidhya/derivative-of-log-loss-function-for-logistic-regression-9b832f025c2d)