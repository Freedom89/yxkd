---
title: Introduction to Hypothesis Testing
date: 2021-07-21 0000:00:00 +0800
categories: [Knowledge, Statistics]
tags: [math]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Problem statement

Want to get started on ab testing? You probably have to first understand hypothesis testing and the following 4 terms:

* Type I Error
* Type II Error 
* Sample Size
* Power 

## Pre-req 

* Some python (or any other programming languages)
* Understanding of basic statistics (High school would be sufficient)
    * Basic distributions, pdf, cdf. 
    * expected value, variance. 
    * central limit theorem, confidence intervals, z-score. 

## Setup 

`requirements.txt`:

```python
numpy==1.19.4
pandas==1.1.5
statsmodels==0.12.1
matplotlib==3.3.3
```

Before we dive in, let's start by generating some random numbers:

In this example, we will use exponential distribution (but you wouldn't know this in real life) - so let's play along:

The exponential function is defined as :

$$
f(x, \beta) =
  \begin{cases}
  	\frac{1}{\beta}e^{(-x/\beta)}& x \ge 0 \\\\
   0 & x < 0
  \end{cases}
$$

$$
E[X] = \frac{1}{\beta},
Var[x] =\frac{1}{\beta^2}
$$

Note, some sites refer exponential function with the rate $\lambda$ parameter with $\lambda = 1/\beta$. 

Now let's import some libraries, define a python function, and generate some random numbers: 

```python
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st


def gen_exp(n_samples: int, size_sample: int, scale_input: float) -> np.ndarray:
    """[summary]

    Args:
        n_samples (int): [number of samples]
        size_sample (int): [each sample size]
        scale_input (float): [the exponential distribution scale parameter]

    Returns:
        np.ndarray: [returns a n_sample x size_sample ndarry]
    """
    np.random.seed(100)
    values: np.ndarray = np.random.exponential(
        scale=scale_input, size=(n_samples, size_sample)
    )
    return values


# dummy generated data 
eg1_n = 10000
eg1_size = 500
eg1_scale = 5
eg1_var = eg1_scale ** 2
# ------ 
# Null hypothesis, we assume the mu0 to be 5
eg1_data = gen_exp(n_samples=eg1_n, size_sample=eg1_size, scale_input=eg1_scale)
eg1_means = np.mean(eg1_data, axis=1)
```


To summarize, this is what the code did:

1. generate some data (that follows exponential distribution)
2. calculate sample mean
3. The population variance is known (more on this in [t-test](#t-test) if you do not know your population variance) to calculate z-statistics $\frac{x-\mu}{\sigma/\sqrt{n}}$.

---

## Introduction

In the above setup, 10000 different samples of size 500 each are generated. In reality, you would only have 1 such sample. E.g suppose you are running a factory line, and you take 0.1% of your supply chain to take measurements. But lets assume somehow you magically are able to take measurements of all your supply chain. 


Now, suppose you want to test whether the assumed population mean (null hypothesis $\mu_0$) is equals to $\mu_0 = 0.5$ (which is the scale parameter) we have to calculate the standardized z-score: 

$$Z = \frac{\bar{x}-\mu_0}{\sigma / \sqrt{n}}$$

```python
null_mean = 5
eg1_z_score = ((eg1_means) - null_mean) / (eg1_var ** 0.5 / eg1_size ** 0.5)
print(eg1_z_score)
"""
array([ 0.34787201,  0.1295498 , -1.64761934, ..., -2.05800225,
        0.25049453,  0.70433965])
"""
```

> **Extra notes:**
>
>    Recall that the distribution of sample means follows normal distribution (due to [central limit theorem](https://en.wikipedia.org/wiki/Central_limit_theorem)). 
>
>    $$
>    Z = \frac{\bar{X}-\mu}{\sigma/\sqrt{n}}
>    $$
>
>    Where:
>
>    * $\bar{X}$ is the sample mean.
>    * $\mu$ is the population mean.
>    * $\sigma$ is the population variance.
>    * $n$ is the sample size. 
{: .prompt-info }

Further more, your management decides to have a 95% confidence level (explained further later). 

```python
error_rate = 0.05
critical_region = st.norm.ppf(error_rate / 2)
eg1_rejected = (eg1_z_score > -critical_region) | (eg1_z_score < critical_region)
print(sum(eg1_rejected) / eg1_n)

"""
0.049
# Notice that this is almost the same as error_rate
"""
```

We will now introduce a few terms:

* The `hypothesis test` 
* `alpha` $\alpha$
* `Type I error` 
* `P-value` 


## Hypothesis testing

In hypothesis testing, we always come up with a `null` hypothesis and an `alternative` hypothesis. 

The `null` and `alternative` are two opposing roads. The null is either rejected or it is not. Only if the null is rejected, can we proceed to the alternative. The "alternative" is simply the other option when the null is rejected; nothing more. 


| $H_0$                                      | $H_a$                                   |
| :----------------------------------------- | :-------------------------------------- |
| Assumption, status quo, nothing new        | Rejection of an assumption              |
| Assumed to be "True"; a given.             | Rejection of an assumption or the given |
| Negation of the research question          | Research question to be "proven"        |
| Always contains an equality $=, \leq,\geq$ | Does not contain equality $\neq,<,>$    |

In any hypothesis testing, we assume that the null is equal to some values, while the alternative is not equal, i.e a two tailed test such as the example above. 

We can also assume the null to be less than or greater than a certain value while the alternative is the opposite that would result in a one tailed test. 

- $H_0 =, H_a \neq$ 
- $H_0 \leq, H_a >$,
- $H_0 \geq, H_a <$

In a two tail test with error rate `0.05`, it means that for any `z-statistics` lower than `-1.96` or higher than `1.96` are rejected (this has to do with [confidence interval](https://en.wikipedia.org/wiki/Confidence_interval)). 

```python
st.norm.ppf(0.975) # 1 - alpha/2, alpha = 0.05
"""
1.959963984540054
"""
```

In the earlier example, this would be our hypothesis:

$$H_0 = 0.5, H_a \neq 0.5 $$

In some sense, z-scores that are above or lower than the critical region are out-liers or extreme points under the (normal) distribution curve that will result in rejection of the null hypothesis. 

>**Extra notes:**
>    - All statistical conclusions are made in reference to the null hypothesis.
>    - As researchers we either **reject** the null hypothesis or **fail to reject** the null hypothesis; we do not **accept** the null.
>      - This is due to the fact that the null hypothesis is assumed to be true from the start; rejecting or failing to rejection an assumption.
>    - If we **reject** the null hypothesis, then we conclude the data supports the alternative hypothesis.
>    - however if we **fail to reject** the null hypothesis, it does not mean we have proven the null hypothesis is "true".
{: .prompt-info }

### Alpha $\alpha$

In the earlier example, **all samples** are actually all **true**; they came from the same distribution, they are **expected** to have the mean 0.5 but yet some of them got rejected! 

let's take a look at some of the sample means that got rejected:

```python
eg1_means[eg1_rejected][0:10]

"""
array([5.44087673, 5.49711468, 4.55158478, 5.56972674, 5.46925766,
       5.74871525, 4.51424667, 5.59588691, 4.41574811, 4.50385256])
"""
```

Hmm, the values are about 10% (0.05) away from the mean (0.5)! 

Indeed, if we see the rejected z-scores means they do seem like outlier if we observe their z-statistics! 

```python
eg1_z_score[eg1_rejected][0:10]
"""
# z-scores that got rejected
array([ 1.97166068,  2.22316444, -2.00537382,  2.54789543,  2.09858404,
        3.3483564 , -2.17235491,  2.66488728, -2.61285386, -2.21883879])
"""
```

This error is known as Type I error and is represented by $\alpha$, which is formally defined as:

> `Alpha` α is the probability of rejecting the null hypothesis when the null hypothesis is true. This is also sometimes referred as `significance level`. 

### Type I error

`Alpha` $\alpha$ is also known as `Type I error` which is also known as `false positive`. 

The formal definition of `type I error`: 

> The type I error rate or significance level is the probability of rejecting the null hypothesis given that it is true. It is denoted by the Greek letter α (alpha) and is also called the alpha level.

We will now refer type I error as alpha $\alpha$. 

### P-value

In the earlier example, when we look at the "extreme" z-scores, we notice that they are "rare" chances of occurring, the question is, how rare? This is where [p-values](https://en.wikipedia.org/wiki/P-value) come in. 

For the formal definition (which is kinda hard to understand):

> In null hypothesis significance testing, the p-value is the probability of obtaining test results at least as extreme as the results actually observed, under the assumption that the null hypothesis is correct.

Let's take a look at the same example:

Note that the P-value for a two-tailed test is always two times the P-value for either of the one-tailed tests. 

```python
alpha = 0.05
p_values = st.norm.sf(abs(eg1_z_score)) * 2  # twosided
print(sum(p_values < alpha))
print(p_values[eg1_rejected][0:10])
"""
# Number of values that got rejected
490
# P-values that got rejected
[0.04864836 0.02620471 0.0449231  0.0108375  0.03585358 0.00081292
 0.0298289  0.00770141 0.00897897 0.02649769]
 """
```

This means that the probability of the rejected samples are quite rare! 

* p-value is the chance that your sample data correctly reflects the population assuming your null hypothesis is true
*  High p value : low surprise. A low p-value makes your default assumption looks stupid.
*  Does the evidence we collected make our null hypothesis looks ridiculous?

## T-test

The above example assumes that we know or is able to assume our population variance, this might not always be true. In that scenario, we use t-test. 

>**Extra Info:**
>
>    As compared to the Z-distribution, the T-distribution is flatter - you want to "play safe" and act upon it. but as $n \geq 30$ it does not matter that much.
>
>   - A Smaller sample size means more sampling error. This sampling error due to small $n$ means a higher probability of extreme sample means. When you only collect 1 sample, the sample could be extreme.
>   - Given the same $\alpha$ and $s$, a smaller $n$ will push the critical values further outward in the tail(s) due to the uncertainty associated with small n. - think of this as collecting evidence.
>   - As sample size increases for t-distribution, it "narrows" down the curve and making it sharper. The larger sample size $n$ leads to a higher degree of freedom $df$.
{: .prompt-info }

For the T-test, we need to calculate Sample variance and degree of freedom.

$$S^2 = \frac{1}{n-1}\sum_i^n (x_i - \bar{x})^2 $$

$$df = n-1$$

```python
# dummy generated data
eg2_n = 20000
eg2_size = 20  # smaller sample size to show the difference
eg2_scale = 5
eg2_var = eg2_scale ** 2
eg2_data = gen_exp(n_samples=eg2_n, size_sample=eg2_size, scale_input=eg2_scale)

# ------ 
# Assume under the null hypothesis is 5 
alpha = 0.05
null_hypo_mean = 5
eg2_means = np.mean(eg2_data, axis=1)
eg2_z_score = ((eg2_means) - null_hypo_mean) / (eg2_var ** 0.5 / eg2_size ** 0.5)
critical_region = st.norm.ppf(alpha / 2)
eg2_z_rejected = (eg2_z_score > -critical_region) | (eg2_z_score < critical_region)
print(sum(eg2_z_rejected) / eg2_n)  # still approximately alpha

sample_s_vars = np.var(eg2_data, axis=1, ddof=1)  # to calculate sample variance
t_statistics = ((eg2_means) - null_hypo_mean) / (
    sample_s_vars ** 0.5 / eg2_size ** 0.5
)  
critical_region = st.t.ppf(alpha / 2, df=len(t_statistics) - 1)
eg2_t_rejected = (t_statistics > -critical_region) | (t_statistics < critical_region)
print(sum(eg2_t_rejected) / eg2_n)
"""
0.0464 # % of type 1 error for z-test - still approximately alpha
0.09655 # % of type 1 error for t-test
"""
```

## Controlling Error

In the earlier example when we look at the rejected means, 

```python
eg1_means[eg1_rejected][0:10]
"""
array([5.44087673, 5.49711468, 4.55158478, 5.56972674, 5.46925766,
       5.74871525, 4.51424667, 5.59588691, 4.41574811, 4.50385256])
"""
```

While for some cases,

```python
eg1_means[~eg1_rejected][0:10]
"""
array([5.07778655, 5.02896822, 4.63158111, 4.64179313, 4.75966314,
       5.07823713, 5.29718464, 5.1069177 , 5.04548296, 5.0073808 ])
"""
```

Notice that for means values such as `4.6315` which is `5-4.6315 = 0.3685` off, the hypothesis test did not reject the null hypothesis. You might not be comfortable with this error, because `0.3685` seems pretty far off, and you ensure that all values that are accepted must be within $\pm 0.35$. 

In hypothesis testing, this is increasing the confidence level by increasing the sample size, but how much to increase? For this, we need to introduce Margin of Error: 

### Margin Of Error

In confidence interval, we have 

$$\bar{X} \pm z_{\alpha/2} * \frac{\sigma}{\sqrt{n}}$$

If we want to have an interval such that:

$$\bar{X} \pm E$$

We can set:

$$E = z_{\alpha/2} * \frac{\sigma}{\sqrt{n}}$$

$E$ is also known as the [Margin of Error](https://en.wikipedia.org/wiki/Margin_of_error) - sometimes annotated with $m$ or $MOE$ in literature.

The formal definition:

>The margin of error is a statistic expressing the amount of random sampling error in the results of a survey.
{: .prompt-info }

To decrease E, we can decrease $z$ which can be done by reducing $\alpha$, or we can increase our sample size $n$. 

### Sample Size for population

Rearranging the variables, 

$$n = \bigg(\frac{z_{\alpha/2}* \sigma}{E} \bigg)^2$$

In the earlier example, we set $\alpha = 0.05\ z_{\alpha/2} = 1.96\ \sigma=5$ Suppose desired error is 0.35,

then:

$$n = (1.96 * 5 / 0.35)^2 = 784 $$

### Adjusting Sample Size

Let's change the sample size to 784 as follows to see the impact of the rejected values.

```python
# dummy generated data
eg3_n = 10000
eg3_size = 784
eg3_scale = 5
eg3_var = eg3_scale ** 2
eg3_data = gen_exp(n_samples=eg3_n, size_sample=eg3_size, scale_input=eg3_scale)

# ----- 
# under null hypothesis, mu0 = 5
alpha = 0.05
null_hypo_mean = 5
eg3_means = np.mean(eg3_data, axis=1)
eg3_z_score = ((eg3_means) - null_hypo_mean) / (eg3_var ** 0.5 / eg3_size ** 0.5)
critical_region = st.norm.ppf(alpha / 2)
eg3_z_rejected = (eg3_z_score > -critical_region) | (eg3_z_score < critical_region)
print(sum(eg3_z_rejected) / eg3_n)
print(eg3_means[eg3_z_rejected][0:10])
print(eg3_means[~eg3_z_rejected][0:10])
"""
0.0494 # still alpha
[4.6383495  5.35335695 5.37160384 5.37822502 5.45501496 4.53971264
 5.41956301 4.47470486 4.50186932 5.41407206] # mean values beyond 0.35 error margin getting rejected
[5.06980888 4.67283548 4.70932442 5.14385203 5.15813739 5.0987326
 4.96519985 5.21819036 5.03102888 4.89815293] # mena values within 0.35 error is still "accepted"
"""
```
Notice that: 

* The value of alpha does not change.
* Values within $5 \pm 0.35$ still get accepted 
* Values out of $5 \pm 0.35$ will be rejected. 

## Type II error 

There is still another type of error, up till now, we only introduced [type I error](#type-i-error) where we wrongly rejected the null hypothesis when it is true. There is also another type of error - what if we fail to reject the null hypothesis, when it is actually false?

> :exclamation:
> <br>
> Note, for this guide we assume that we are able to acquire the true population variance (which is not possible in reality) - This is to illustrate the concept behind Type II Error & Power. In practice you might consider using sample variance and t-test instead!
{: .prompt-info }

Let's take a look at an example:

```python
# generate dummy data, note that the data is now generated with a different parameter
eg4_n = 20000
eg4_size = 100
eg4_scale = 7
eg4_var = eg4_scale ** 2 # population variance is known
eg4_data = gen_exp(n_samples=eg4_n, size_sample=eg4_size, scale_input=eg4_scale)

# but we still assume under the null hypothesis to be equal to 5. 
alpha = 0.05
eg4_means = np.mean(eg4_data, axis=1)
null_hypo_mean = 5
known_var=eg4_var # not possible in reality
eg4_z_score = ((eg4_means) - null_hypo_mean) / (known_var ** 0.5 / eg4_size ** 0.5)
critical_region = st.norm.ppf(alpha / 2)
num_rejected = (eg4_z_score > -critical_region) | (eg4_z_score < critical_region)
print(sum(num_rejected))
print(1-sum(num_rejected) / eg4_n) # Type 2 error
"""
16274 # number of samples accepted even though the true mean is not 5! 
0.18630000000000002 # Type 2 error
"""
```

In reality, we should have rejected 100% of them, but we only rejected about 81% of them! So **we failed to reject 19% when the alternative is true.** 

(In this case we know the alternative is 7, more on that later)

The formal definition:

> The second kind of error is the failure to reject a false null hypothesis as the result of a test procedure. This sort of error is called a type II error (false negative) and is also referred to as an error of the second kind.
{: .prompt-info }

Type II error is also known as false negative, and the probability is represented $\beta$. 


### Calculating Type II error

To calculate the Type II error, 

   * need to assume an alternative hypothesis. 
   * have to select a $\mu_a$ that satisfies the alternative hypothesis to calculate the probability of Type II error
   * Calculate the overlapping distributions under the null hypothesis and alternate hypothesis. 

There is no "universal" type II error. It is different for every $\mu_a$ that satisfies the alternative hypothesis.

$$H_0: \mu_0 = 5, H_a: \mu_a = 7$$

```python
null_scale = 5  # mu0
alt_scale = 7 # mu_a, the specific value of the alternate hypothesis which happens to be the true distribution parameter. 
known_sd = 7 # population s.d is known - which is based on the true population distribution
n = 100
alpha = 0.05
z_alpha = -st.norm.ppf(alpha / 2)
# Calculating the overlapping area by calculating the axis where the distributions overlap. 
left_tail = -z_alpha + (null_scale - alt_scale) / (known_sd / n ** 0.5)
right_tail = z_alpha + (null_scale - alt_scale) / (known_sd / n ** 0.5)
type_2_error = st.norm.cdf(right_tail) - st.norm.cdf(left_tail)
print(type_2_error)
"""
0.18481101024000066 - approximately `eg4` type II error rate. 
"""
```

Which is approximately same as example above `print(1-sum(num_rejected) / eg4_n)`. 

### Some Math

A little bit of mathematics to understand to understand the formula of `left_tail` and `right_tail`:

By definition, Type II error is defined as: 

$$P( \text{accept }H_0 | H_a \text{ is true}) $$

This happens when there is an intersection of of two distributions. To calculate this value, we need to calculate area under the curve where the two distributions overlap.

In a two tailed test: 

$$
\begin{align}
    & P(|\bar{X}| < \bar{x}_{crit|H_0} | H_a ) \\
    & = P( \bar{x}_{left,crit|H_0}  < \bar{X} < \bar{x}_{right,crit|H_0}  | H_a) \\
    & =  P( \frac{\bar{x}_{l,c|H_0} - \mu_a}{\sigma/\sqrt{n}} < Z < \frac{\bar{x}_{r,c|H_0}-\mu_a}{\sigma/\sqrt{n}} ) \\
    & = P( \frac{\bar{x}_{l,c|H_0} - \mu_0 + \mu_0 - \mu_a}{\sigma/\sqrt{n}} < Z < \frac{\bar{x}_{r,c|H_0}-  \mu_0 + \mu_0-\mu_a}{\sigma/\sqrt{n}} )\\
    &= P( -z_{\alpha/2}+ \frac{\mu_0-\mu_a}{\sigma/\sqrt{n}}< Z < z_{\alpha/2} + \frac{\mu_0-\mu_a}{\sigma/\sqrt{n}} )
\end{align}
$$

**Extra notes:**
>    $\frac{\mu_1 - \mu_2}{s}$ is also known as the [Cohen's d effect size](https://en.wikipedia.org/wiki/Effect_size#Cohen's_d).
{: .prompt-info }

Thus the new left (and right) tail is given by the sum of null hypothesis $z_\alpha$ and the difference between the two means divided by the sample variance. 

```python
left_tail = -z_alpha + (null_scale - true_scale) / (known_var ** 0.5 / n ** 0.5)
```

In order to control the Type II error, we need to first understand Statistical Power. 

## Power 

The formal definition: 

> The power of a binary hypothesis test is the probability that the test rejects the null hypothesis when a specific alternative hypothesis ) is true — i.e., it indicates the probability of avoiding a type II error. 
{: .prompt-info }

Thus, by definition,

$$\text{Power} = 1 - \beta $$

### Calculating Power (Example)

In order to start understanding power, lets introduce an example:

The null hypothesis is assumed to be 5 and we want to estimate with 95% confidence with 0.5 margin of error. 

```python
Error_ci = 0.5
null_mean = 5 # this is x-bar
"""
In this case when we are using z-statistics, population variance is known.
And the population s.d is equal to the true population mean in this specific context
(which is the alternative hypothesis based on the artificially generated data)
"""
known_sd = 5.5 
alpha = 0.05
z_alpha = -st.norm.ppf(alpha / 2)
sample_size = (z_alpha * known_sd / Error_ci) ** 2
print(sample_size)
"""
464.8165173039894
"""
```

In order to calculate Power (or type II error), we need to assume a specific value of the alternative hypothesis $H_a = 5.5$ as previously mentioned, given that the alternative hypothesis is equal to the null hypothesis plus the margin of error, we would expect the z-score would be exactly in the confidence interval boundary. 

$$H_0: \mu_0 = 5, H_a : \mu_a = 5.5$$

```python
alt_mean = 5.5 
z_stats = (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
print(z_stats)
"""
The z-statistics which is the left tail at the two tail 95% confidence interval of the alternate hypothesis
-1.9599639845400547
"""
```

What is the probability of rejecting the null hypothesis $H_0 = 5$ when the alternative is true $H_a=5.5$? By intuition, it is exactly `0.5`! 

This is because you are at the confidence interval boundary, you are equally unsure on both distributions. To illustrate, recall the derivation above on calculating power:

$$
\begin{align}
    & P(|\bar{X}| < \bar{x}_{crit|H_0} | H_a ) \\
    &= P( -z_{\alpha/2}+ \frac{\mu_0-\mu_a}{\sigma/\sqrt{n}}< Z < z_{\alpha/2} + \frac{\mu_0-\mu_a}{\sigma/\sqrt{n}} )
\end{align}
$$

```python
left_tail = -z_alpha + (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
right_tail = z_alpha + (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
type_2_error = st.norm.cdf(right_tail) - st.norm.cdf(left_tail)
power = 1 - type_2_error  # %%
print(power)
"""
0.5000442877191609
"""
```

> **Extra notes:**
>   - Controlling $\alpha$ is easy, simply choose
>   - Controlling $\beta$ is abit more complicated
>   - The goal is to align the $\alpha$ and $\beta$ regions in the $\mu_0$ and $\mu_a$ distributions respectively
>   - Since the means $\sigma$ and critical values are set, we can "manipulate" the sample size $n$ to generate a standard error that brings $\alpha$ and $\beta$ into alignment at $c$
>   - This new $n$ will create a new $\bar{x}_{crit}$ value for our decision rule.
>   - Since we are now controlling Type II error, we CAN use the phrases "reject $H_0$" or "accept $H_0$.
{: .prompt-info }

## Influencing Power

As mentioned previously, to control the Type II Error is also to control the power since they are related by the equation $Power = 1 - \beta$. The process of doing this is known as power analysis. Power analysis is normally conducted before the data collection.  

The formal definition:

> Power analysis is the procedure that researchers can use to determine if the test contains enough power to make a reasonable conclusion. 
{: .prompt-info }

Alternatively, 

> Power is the probability that a test of significance will detect a deviation from the null hypothesis, should such a deviation exist.
{: .prompt-info }

There are a few ways to adjust the power:

* Adjusting $\alpha$ - but unlikely to happen 
* increasing sample size, in that case, how much to increase?

There are other ways but  usually not feasible, for example:

* enforce a smaller margin of error by decreasing the variance across subjects - but you might not have control over your samples 
* Changing it to one tail test - unless you are very confident in an actual study / very strong domain knowledge. 

### Increase Power by sample size

In order to control the Power by sample size, we need to decide on the effect that we want to detect. For example, if there is a derivation of 0.5 that is present, we want to have a 80% chance of detecting it. We can formulate this with the following hypothesis: 

$$H_0 = 5, H_a = 5.5 $$

> **Online Calculator!**
>    There are online calculators such as [this](https://www.stat.ubc.ca/~rollin/stats/ssize/n1.html) or [that](http://powerandsamplesize.com/Calculators/Test-1-Mean/1-Sample-Equality) as well as libraries that are available for free. Feel free to try it out with:
>
>    * Power $1-\beta$ = 0.8
>    * Type I error rate $\alpha = 0.05$ or $5\%$
>    * True mean $\mu_a \text{ or } \mu_1= 5.5$ 
>    * Null mean $\mu_0 = 5$
>    * known s.d $\sigma = 5.5$
{: .prompt-info }

```python
z_alpha = st.norm.ppf(1 - 0.01/2)
# Alpha value at right tail since alternative is bigger than null
z_beta = st.norm.ppf(0.8) # Beta power = 0.8
null_mean = 5
alt_mean = 5.5
known_sd = 5.5
# Derivation of this formula is at the math section right after
sample_size = (z_alpha + z_beta) ** 2 * known_sd**2 / (null_mean - alt_mean) ** 2
print(sample_size)
"""
949.7144478562396
"""
```

#### Some Mathematics

To control our power to be a certain value - 0.8 in this case, is to restrict the overlaping area of the two distributions between the null and alternative hypothesis. In this case, since the alternative hypothesis is greater than the null hypothesis, the intersection point is where the right tail of the null hypothesis equates to the left tail of the alternative hypothesis:

$$\mu_0 + z_{\alpha/2} \frac{\sigma}{\sqrt{n}}=\mu_a - z_\beta\frac{\sigma}{\sqrt{n}}$$

Solving for $n$ gives us:

$$n = \frac{(z_a+z_\beta)^2 \sigma^2}{(\mu_0 - \mu_a)^2}$$

#### Sample Size vs Power

To verify our new `sample_size` where `z_beta = st.norm.ppf(0.8)`: 

```python
alt_mean = 5.5
known_sd = 5.5
null_mean = 5
alpha = 0.05
z_beta = st.norm.ppf(0.8) 
z_alpha = -st.norm.ppf(alpha / 2)
# our new sample size
sample_size = (z_alpha + z_beta) ** 2 * known_sd ** 2 / (null_mean - alt_mean) ** 2
print(sample_size)
z_stats = (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
print(z_stats)
left_tail = -z_alpha + (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
right_tail = z_alpha + (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
type_2_error = st.norm.cdf(right_tail) - st.norm.cdf(left_tail)
power = 1 - type_2_error  # %%
print(power)

"""
949.71444785624 # This is the sample required to have 80% power
-2.801585218112969
0.8000009605622265
"""
```

As we are collecting more data which resulted in a larger sample size, we are now "more" certain that the null hypothesis should be rejected. 

### Decreasing Margin Of Error

Alternatively, we can also `decrease the error` - which is usually not possible in practice. 

In the earlier example, when the alternative hypothesis $H_a = 5.5$ with 95% confidence interval, 0.5 margin of error, the power $\beta = 0.5$. To increase the power by 0.3, we can decrease the margin of error by 30%. 

```python
# Increase in power = 0.3
# 0.5 * (1- increase in power ) = 0.5 * 0.7 = 0.35
Error_ci = 0.35
null_mean = 5
known_sd = 5.5
alpha = 0.05
z_alpha = -st.norm.ppf(alpha / 2)
sample_size = (z_alpha * known_sd / Error_ci) ** 2
print(sample_size)
alt_mean = 5.5
z_stats = (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
print(z_stats)
left_tail = -z_alpha + (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
right_tail = z_alpha + (null_mean - alt_mean) / (known_sd / sample_size ** 0.5)
type_2_error = st.norm.cdf(right_tail) - st.norm.cdf(left_tail)
power = 1 - type_2_error  # %%
print(power)
"""
948.6051373550805 # Sample size required
-2.7999485493429357 # z-score
0.7995424479338836  # power
"""
```

As expected, the result is similar. Thus, with a power of 80% to detect an difference of 0.5, any deviation from $5 \pm 0.35$ will result in the rejection of the null hypothesis and conclude that the evidence is supportive of the alternative hypothesis. 

### Increase Alpha

How much to adjust $alpha$ is not straight forward, and is usually done by plotting power curves.

For example, to get a power of 0.8 in the same example, we increase $\alpha$ from 0.05 to 0.266. 

```python
Error_ci = 0.5
sample_mean = 5
known_sd = 5.5
alpha = 0.266 # increase from 0.05 to 0.25
z_alpha = -st.norm.ppf(alpha / 2)
sample_size = (critical_region * known_sd / Error_ci) ** 2
print(sample_size)
alt_mean = 5.5 # or the alteranate hypothesis mean
z_stats = (sample_mean - alt_mean) / (known_sd / sample_size ** 0.5)
print(z_stats)
left_tail = -z_alpha + (sample_mean - alt_mean) / (known_sd / sample_size ** 0.5)
right_tail = z_alpha + (sample_mean - alt_mean) / (known_sd / sample_size ** 0.5)
type_2_error = st.norm.cdf(right_tail) - st.norm.cdf(left_tail)
power = 1 - type_2_error  # %%
print(power)
"""
464.8165173039894
-1.9599639845400547 # This value is less than z_alpha of -1.111, so we reject null hypothesis
0.8027436164758492 # but the power has increased to 0.8
"""
```

## Summary

The following table gives a summary of the 4 scenarios of hypothesis testing.

|                                       |                                Null is true                                 |                           Null is false                            |
| :-----------------------------------: | :-------------------------------------------------------------------------: | :----------------------------------------------------------------: |
| Decision about null <br> Don't reject | Correct Inference <br> (true negative = $1-\alpha$) <br> significance level |           Type II error  <br> (False negative = $\beta$)           |
|    Decision about null <br> Reject    |                Type I error <br> (false positive = $\alpha$)                | correct Inference  <br>     (true positive = $1-\beta$) <br> power |

## Additional readings

* [A Gentle Introduction to Statistical Power and Power Analysis in Python
](https://machinelearningmastery.com/statistical-power-and-power-analysis-in-python/)
* Wikipedia links 
    * [Power of a test](https://en.wikipedia.org/wiki/Power_of_a_test)
    * [Type I and II errors](https://en.wikipedia.org/wiki/Type_I_and_type_II_errors
)
* Useful definitions
    * [Understanding hypothesis testing terms](https://www.cs.rpi.edu/~leen/misc-publications/SomeStatDefs.html){target="_blank}
* [Understanding P-value](https://www.youtube.com/watch?v=9jW9G8MO4PQ)
* Power calculators 
    * [stats.ubc online calculators](https://www.stat.ubc.ca/~rollin/stats/ssize/){target="_blank}
    * [Power and sample size online calculators](http://powerandsamplesize.com/Calculators/)
* What is power? What affects statistical power?
    * [statistical teacher.org](https://www.statisticsteacher.org/2017/09/15/what-is-power/)
    * [Factors that affect the power of a statistical procedure](https://web.ma.utexas.edu/users/mks/statmistakes/FactorsInfluencingPower.html)
    * [Understanding Power Analysis in AB Testing](https://towardsdatascience.com/understanding-power-analysis-in-ab-testing-14808e8a1554)
