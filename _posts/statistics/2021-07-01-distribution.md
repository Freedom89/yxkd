---
title: Various Statistical Distributions
date: 2021-07-01 0000:00:00 +0800
categories: [Knowledge, Statistics]
tags: [math]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Distributions

I try to provide a quick overview of the distributions here, the use case, and how they are related to one another. I will also try to provide certain mathemathical derivations where I think its important. 

`Extra Notes` refers to extra information about the distribution itself.

`Special Notes` refers to how this distribution is related to other distributions or use cases.

## Bernoulli

An event sucess with probability $p$ and failure $1-p$

$$ 
f(k,p) = p^k (1-p)^{1-k}, k\in \{0,1\}
$$

Special notes:

* The sum of independent Bernoulli (each event has a different $p$) is known as the poisson binomal distribution which is a generalization of the binomial distribution. 
* If $p$ remains the same across events, then the sum follows binomal distribution. 

[Wiki on Bernoulli](https://en.wikipedia.org/wiki/Bernoulli_distribution)

## Geometric

Probability before first sucess occurs. 

$$
Pr(X=k) = (1-p)^{k-1} p
$$

Special notes:

* Special case of the negative bionimal distribution.


[Wiki on Geometric](https://en.wikipedia.org/wiki/Geometric_distribution)

## Hypergeometric

Having k successes from N draws without replacement. 

The pdf is given by:

$$
Pr(X=k) = \frac{ \binom{K}{k} \binom{N-K}{n-k}  }{\binom{N}{n}}
$$

Where:

* $N$ is the population size
* $K$ is the total possible success
* $n$ is the number of draws 
* $k$ is the number of success required 

Special notes: 

* Identical to one-tailed version of Fisher's exact test. 
* Fisher's exact tests is used in analysis of contingency tables. (A contingency table is also known as cross tabulation table)

[Wiki on HyperGeometric](https://en.wikipedia.org/wiki/Hypergeometric_distribution)

## Binomal 

K event success out of N possible draws.

$$
Pr(X=k) = \binom{n}{k} p^k (1-p)^{n-k}
$$

Where:

* $n$ is total events
* $k$ is number of success 

Special notes:

* Special case of the poisson binomial. 
* Can be approximated to normal distribution when $n$, $np$ and $npq$ is sufficiently large. $X \sim N(np,npq)$
* Can be approximated to poisson distribution when $n$ is large but $np$ is small. $X \sim P(\lambda,\lambda), \lambda = np$
* Similiar to beta distribution under certain conditions. 
    * Beta distribution is also used as prior in bayesian inference. 

[Wiki on Binomial](https://en.wikipedia.org/wiki/Binomial_distribution)

### Poisson Binomial

Number of $k$ successes within $n$ trails but each trail follows a different probability of success $p_i$.

$$
Pr(K=k) = \sum_{A\in F_k} \prod_{i \in A}p_i \prod_{j\in A^c} (1-p_j)
$$

Where:

* $F_k$ is all the possible $k$ success out of $n$ events. E.g if you have 3 events, then $F_2 = \{\{1,2\},\{1,3\},\{2,3\}\}$. 
* $A^c$ is the complement of $A$. 

[Wiki on Poisson binomial](https://en.wikipedia.org/wiki/Poisson_binomial_distribution)


### Negative Binomial

Probability of $r$ successes and $k$ failures with probability of success as $p$ within $r+k$ trails. 

$$
Pr(X=k) = \binom{k+r-1}{r-1}(1-p)^kp^r
$$

Where: 

* $r$ is the number of success
* $k$ is the number of failure 
* $p$ is the probability of success
  
Extra notes:

* The final event must be a success. 
* This means that the events before must have exactly $r-1$ success, hence $\binom{k+r-1}{r-1}$

[Wiki on Negative binomial](https://en.wikipedia.org/wiki/Negative_binomial_distribution)


### Multinomial

Generalization of the binomial distribution, where each event can take on different types of success with probability $p_i$. 

For example, given 6 dice tosses, whats the probability that you will have all six outcomes? (one for each side of the die)

$$
Pr(X_1 = x_1,...,X_k = x_k) = \frac{n!}{x_1!\cdots x_k!}p_1^{x_1} \cdots p_k^{x_k}
$$

Extra Notes:

* The term $p_1^{x_1} \cdots p_k^{x_k}$ represents the probability of the distribution $X_1 = x_1, ... , X_k = x_k$ happening. 
* The term $\frac{n!}{x_1!\cdots x_k!}$ represents the number of ways the event can happen. 

[Wiki on Multinomial](https://en.wikipedia.org/wiki/Multinomial_distribution)


## Uniform

The (continuous distribution) measures the probability of an outcome between two intervals.

$$
\begin{aligned}
f(x) &= 
\begin{cases}
\frac{1}{b-a}, &\text{if $x \in [a,b]$ } \\[2ex]
0 &\text{otherwise}
\end{cases}
\\
F(x) &=
\begin{cases}
0, &\text{for $x<a$} \\[2ex]
\frac{x-a}{a-b} &\text{for $a \leq x \leq b$} \\[2ex]
1 &\text{for $x>b$}
\end{cases}
\end{aligned}
$$


Special notes:

* If X has a standard uniform distribution $X \sim U[0,1]$ then $Y=X^n$ has a beta distribution with parametrs $(1/n,1)$. This also implies that uniform distribution is also beta(1,1). 

[Wiki on uniform](https://en.wikipedia.org/wiki/Continuous_uniform_distribution)

# Beta

The beta distirubtion is a probability distribution parameterized by two positive shape parameters denoted by $\alpha,\beta$ with a limited range, (0,1). The beta distribution has been applied to model the behavior of random variables limited to intervals of finite length in a wide variety of disciplines.

An example of usage is `batting averages`. 

$$
\begin{aligned}
f(x,\alpha,\beta) &= \frac{x^{\alpha-1}(1-x)^{\beta-1}}{B(\alpha,\beta)}, \\ \text{where} &:\\
 B(\alpha,\beta) &= \frac{\Gamma(\alpha)\Gamma(\beta)}{\Gamma(\alpha+\beta)} \\
 \Gamma(x) &= (x-1)! &\text{if $x \in \mathbb{Z^+}$}\\
 \Gamma(x) &= \int_0^\infty z^{x-1}e^{-x} dz &\text{$\mathcal{R}$(x) >0}
\end{aligned}
$$

Extra notes:

* More notes on gamma function $\Gamma$ can be found in [referrences](#referrences).

Special notes:

* Conjugate prior for binomial.
* The generalization to multiple variables is called a Dirichlet distribution.
  
Links:

* [Wiki on beta](https://en.wi_kipedia.org/wiki/Beta_distribution)
* [stats exchange on intuition behind beta distribution](https://stats.stackexchange.com/questions/47771/what-is-the-intuition-behind-beta-distribution)
* [Example on battling averages](https://sjster.github.io/introduction_to_computational_statistics/docs/Production/Distributions.html#beta-distribution)

## Dirichlet

Just as the beta distribution is the conjugate prior for a binomial likelihood, the Dirichlet distribution is the conjugate prior for the multinomial likelihood. It can be thought of as a multivariate beta distribution for a collection of probabilities (that must sum to 1).

$$
f(y_1,...,y_K|\alpha_1,...,\alpha_K) = \frac{\Gamma(\sum_{k=1}^K \alpha_k)}{\prod_{k=1}^K \Gamma(\alpha_k)} \cdot p_1^{\alpha_1-1} \cdot ... \cdot p_K^{\alpha_K-1}
$$

$$
Y_1,...,Y_k >0, \sum_{k=1}^K Y_k =1, \alpha_k >0, k\in \{1,...K\}
$$

Special notes:

* Conjugate prior for multinomial
  
[Wiki on Dirichlet](https://en.wikipedia.org/wiki/Dirichlet_distribution)


## Poisson

The probability of a given number of events occuring within a period of time. e.g number of earthquakes within a year. 

$$
Pr(X=k) = \frac{\lambda^k e^{-\lambda}}{k!}
$$

Extra notes: 

* Poisson distribution is widely used in queuing theory to model arrival and service rates. 

Special notes:

* Is closely related to exponential distribution. 

[Wiki on Poisson](https://en.wikipedia.org/wiki/Poisson_distribution)


## Exponential

While poisson distributions models the number of events within a period of time, exponential distributions model the time until next event. 


$$
\begin{aligned}
f(x) &= 
\begin{cases}
\lambda e^{-\lambda x}, &\text{$ x \geq 0$} \\[2ex]
0 &\text{$x<0$}
\end{cases}
\\
F(x) &=
\begin{cases}
1-e^{-\lambda x}, &\text{$x \geq 0$} \\[2ex]
0 &\text{$x < 0$} \\[2ex]
\end{cases}
\end{aligned}
$$


Extra notes: 

* It has the memorylessess property. 
* Sometimes this is represented with the _scale parameter_ $\beta = 1/\lambda$

[Wiki on Exponential](https://en.wikipedia.org/wiki/Exponential_distribution)

## Double exponential

The double exponential (or Laplace) distribution generalizes the exponential distribution for a random variable that can be positive or negative. The PDF looks like a pair of back-to-back exponential PDFs, with a peak at 0.

The laplace distribution is used for modeling in signal processing, various biological processes, finance and economics. 

$$
\begin{aligned}
f(x|\mu,b) &= \frac{1}{2b}\exp\bigg(-\frac{|x-\mu|}{b}\bigg)\\
&= 
\begin{cases}
\exp\Big(-\frac{\mu-x}{b}\Big) &\text{if $x < \mu$}\\[2ex]
\exp\Big(-\frac{x-\mu}{b}\Big) &\text{if $x\geq \mu$}
\end{cases}
\end{aligned}
$$

Extra notes:

* Here, $\mu$ is a location parameter and $b>0$, which is sometimes referred to as the diversity, is a scale parameter. If $\mu=0$ and $b=1$, the positive half-line is exactly an exponential distribution scaled by 1/2.

[Wiki on Laplace](https://en.wikipedia.org/wiki/Laplace_distribution)

## Gamma

The Gamma distribution is used to model the time taken for ‘n’ independent events to occur. It has two parameters, shape $\alpha$ and rate $\beta$. Sometimes in different literature it can also take shape $k$ and scale $\theta$.

Example: Time taken for 4 failures to happen in your machine. 

$$
f(x) = \frac{\beta^\alpha}{\Gamma(\alpha)}x^{\alpha-1}e^{-\beta x} \quad x,\alpha,\beta >0
$$

Extra notes:

* The shape parameter $\alpha$ can be interpreted as the number of events that we are waiting on to happen. The rate parameter $\beta$, as the name indicates, is the rate at which events happen. In the case where $\alpha=1$, or we are waiting for the first event to happen, we get the exponential distribution

Special notes:

* It can be derived from the CDF of a poisson distribution by computing the probability of a number of events across time t. 
* The exponential, Erlang chi-square are special cases of the gamma distribution. 
* Conjugate prior for exponential or poisson. 

[Wiki on Gamma](https://en.wikipedia.org/wiki/Gamma_distribution)

## Inverse Gamma

Replace $x$ with $1/x$ of gamma distribution. 

$$
f(x) = \frac{\beta^\alpha}{\Gamma(\alpha)}(1/x)^{\alpha-1}e^{-\beta/x} \quad x,\alpha,\beta >0
$$


Special notes:

* Conjugate prior for $\sigma^2$ in normal likelihood with known mean $\mu$

[Wiki on Inverse Gamma](https://en.wikipedia.org/wiki/Gamma_distribution)

## Normal

No introduction required, right?

$$
f(x|\mu,\sigma^2) = \frac{1}{\sqrt{2\pi\sigma^2}}\exp \Bigg(- \frac{(x-\mu)^2}{2\sigma^2}\Bigg)
$$

[Wiki on Normal](https://en.wikipedia.org/wiki/Normal_distribution)

## LogNormal

Can be used to model the disease parameters such as the reproduction number for epidemics.

$$
f(x|\mu,\sigma^2) = \frac{1}{x\sqrt{2\pi\sigma^2}}\exp \Bigg(- \frac{(\ln x-\mu)^2}{2\sigma^2}\Bigg)
$$


[Wiki on LogNormal](https://en.wikipedia.org/wiki/Log-normal_distribution)

## Student-t

The t-distribution is a bell-shaped distribution, similar to the normal distribution, but with heavier tails. It is symmetric and centered around zero. The distribution changes based on a parameter called the degrees of freedom. 

Special notes:

* Used when population variance is not known.

[Wiki on student-t distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution)

## Chi-square

If $Z_i$ are i.i.d normal random variables, then the sum of squares $Q = \sum_i Z_i^2$ will follow:

$$
Q \sim \chi_k^2
$$

The chi-square distribution is a right-skewed distribution. The distribution depends on the parameter degrees of freedom, similar to the t-distribution. 

Special notes:

* Primarily used for hypothesis testing. 
    * One sample variance 
    * Goodness of fit
    * test of independence

[Wiki on Chi-square](https://en.wikipedia.org/wiki/Chi-squared_distribution)

## F

Ratio of two chi-squares will be the F-distribution, it is parameterized by the two degree of freedom.

$$
X = \frac{S_1/d_1}{S_2/d_2}
$$

Where $S_1,S_2$ are i.i.d chi-square distributions with respective degree of freedom $d_1,d_2$. 

Special notes:

* F-tests is one of the calculation done when performing an ANOVA. 

[Wiki on F-distribution](https://en.wikipedia.org/wiki/F-distribution)

## Referrences 

* [Introduction to common distributions](https://sjster.github.io/introduction_to_computational_statistics/docs/Production/Distributions.html#)
* [More on gamma function](https://towardsdatascience.com/gamma-function-intuition-derivation-and-examples-5e5f72517dee)