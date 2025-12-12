
# Different Approaches, Consistent Findings: How Researchers Measure Air Pollution’s Toll on Life

<br>

![](images/clipboard-2308807653.png)

<br>

Air pollution isn’t a distant, abstract problem—it’s a crisis that is
actively and brutally cutting years off our lives. The evidence is
overwhelming. For e.g. exposure to harmful particles in the air,
especially PM2.5 (particles less than 2.5 microns in diameter), is
directly responsible for millions of premature deaths around the globe
every year. Researchers have developed various rigorous methods to
measure the loss in life expectancy resulting from breathing polluted
air, and the stakes couldn’t be higher!

***In this post, I dive deep into one of these methods used by Apte et
al. (2018)*** in their paper: [*Ambient PM2.5 Reduces Global and
Regional Life
Expectancy*](https://pubs.acs.org/doi/10.1021/acs.estlett.8b00360), to
quantify the loss of life expectancy resulting from air pollution. ***My
focus in this post is to dive into the methods underlying this paper and
not the results of the paper***. I’ll ***walk through a hypothetical
simplified example that lays out the math and the intuition*** which
will hopefully equip you with the background needed to understand this
and other similar papers in the literature.

In the end, I’ll also briefly ***touch on other, often complementary
research methods from the air pollution literature that connect air
pollution and life expectancy***. But, the main focus of this post will
be on Apte paper’s method, which uses among other things life tables to
figure out the loss of life expectancy due to air pollution. Other
research methods are equally important and will likely be explored in
detail in future blog posts. But, to catch a brief overview of these
methods, see the ***“Other Research Methods Exploring the Connection
between Air Pollution and Health”*** section of this post.

<br>

> ***Each research method has its own strengths and limitations, leading
> to variations in specific estimates. However, the broader conclusion
> remains consistent across approaches—air pollution is significantly
> impacting life expectancy. This is the key takeaway.***

<br>

## Motivation and the Big Picture Urgent Message!

When I first started working on air pollution, I conducted a
meta-analysis of the literature. Navigating it took time—there were many
moving parts, unfamiliar concepts, math, and diverse research
methodologies. The motivation behind this blog post is twofold:

- First, it helps me consolidate what I’ve learned so far. Of course my
  understanding may still have holes in it, so I am happy to hear your
  thoughts in case you find any unintentional mistakes on my part. If
  you do find any mistakes, please write to me at
  aarshbatra.in@gmail.com with a description of the issue. Having said
  that - one important thing to note is: consistent with biteSizedAQ’s
  tenets, I have written this post avoiding unnecessary jargon wherever
  possible, so should hopefully be accessible to a wide range of
  audience. This means that some sections are deliberately simplified to
  focus on core concepts and that is a design choice. I think there are
  a ton of papers out there which go into the technical nuances of the
  Math and the calculations, so here the objective is to take a step
  back and focus on big picture broad ideas to build intuition, which
  would then later serve as the foundation for diving into the
  technicalities.

- Second, for anyone new to the field, I hope this serves as a broad
  overview of the vast body of research that has consistently shown one
  undeniable truth—air pollution shortens lives.

There will always be room for more research, and those efforts are
crucial. But there is no room left for inaction. The time to take action
on reducing air pollution was yesterday—today is already too late!

As long-term cohort studies expand beyond the Global North—where most
air pollution health research has been concentrated—we will only see
more alarming outcomes. The reality is clear: air pollution is
significantly worse in the Global South, and so are its consequences for
life expectancy. The numbers we have now are likely already
underestimating the true scale of harm.

There is no excuse to wait. If we care about future generations living
long, healthy lives in clean air, that commitment must be reflected in
our actions—now.

<br>

> ***Every day, toxic air robs us of precious time with our loved ones.
> For policymakers, understanding the number of years lost due to
> pollution isn’t an academic exercise—it’s a call to immediate action.
> For scientists and health advocates, it provides concrete evidence
> that even small reductions in pollution can save lives. For everyone,
> it’s a stark reminder that our air is poisoning us, and we must act
> now to protect our health and our future.***

<br>

## Breaking Down the Key Concepts

I’ll start with some key concepts before we get into the Life Tables
method explored in the Apte paper:

### 1. Life Expectancy: The Real Cost of Pollution

**What It Is:**  
Life expectancy at birth is the **average number of years a person in a
given region is expected to live** if they experience the **current
age-specific death rates throughout their lifetime**, assuming
conditions remain unchanged. It reflects the cumulative impact of
**health risks at all stages of life**, from infancy to old age,
providing a comprehensive measure of overall population health. This is
more than just a statistic—it reflects the cumulative impact of all
health risks in an environment, including the effect of air pollution on
lifespan.

Even though it’s called “life expectancy at birth,” it doesn’t just
describe how long infants live—it estimates the **average number of
years a newborn would live if they were exposed to today’s age-specific
death rates throughout their entire life**. This is why we calculate it
by summing **all person-years lived across all age groups** and dividing
by the initial population size.

If we only looked at the **first age group (e.g., 0–4 years)**, we would
only measure how well infants survive their early years, ignoring the
fact that most people live well beyond childhood. Since mortality rates
vary across different age groups—being **higher at infancy and old age
but lower during youth and middle age**—life expectancy must account for
these variations. By considering **the full range of life experiences**,
life expectancy at birth gives a more complete and comparable measure of
population health.

**Why This Statistic Is Very Useful:**

- I**t is easy to understand.**

- **It captures the full impact of health risks:** If a population has
  high infant mortality, it will lower life expectancy at birth​, but if
  more people survive into old age, life expectancy at birth​ reflects
  that too.

- **It allows for comparisons across regions and time:** Because it
  includes **all age groups**, life expectancy at birth provides a
  useful way to compare different populations, regardless of differences
  in birth rates or age distributions.

- **It helps policymakers identify problems:** If life expectancy is
  low, it signals major health risks—whether from **high childhood
  mortality, pollution, poor healthcare, or high elderly death rates**.

**The Big Picture:**  
If a community’s life expectancy is significantly lower than it should
be, it signals that harmful factors (e.g. toxic air, etc) are cutting
lives short. For example, imagine two hypothetically identical cities
that differ in one aspect: City A, with clean air, boasts an average
life expectancy of 80 years, while City B, plagued by severe air
pollution, averages 78 years. That two-year gap in average life
expectancy represents shows that in City B, people live on average 5
years less, because of long-term exposure to pollutants.

### 2. PM2.5: The Silent Killer

**What Is PM2.5?**  
PM2.5 refers to ultra-fine particulate matter that is less than 2.5
microns wide—so small that it can penetrate deep into our lungs and even
enter our bloodstream. It is one of many pollutants, but it’s tiny size
let’s it sneak into places in our body that lead to all sorts of health
concerns.

**The Impact:**  
These tiny particles are linked to deadly diseases such as heart
attacks, strokes, lung cancer, and severe respiratory infections. Each
exposure to PM2.5 delivers a direct, harmful hit to our health. Consider
historical events like the 1952 Great Smog of London, when a deadly
blanket of pollution led to thousands of excess deaths in just a few
days. While extreme, the example starkly illustrates how quickly toxic
air can become fatal. Similar events are everyday reality for regions
like the Indo-Gangetic Plains, spanning cities like Delhi, Lahore among
others.

### 3. The Global Burden of Disease (GBD) Study

**What It Is:**  
The GBD study is a massive, worldwide effort that compiles and
standardizes health data from hundreds of research studies. It provides
detailed, age-specific death rates and estimates of how various risk
factors—including air pollution—contribute to mortality.

**Why It Matters:**  
GBD forms the backbone of much of the research on air pollution’s deadly
impact. When Apte et al. (2018) use GBD data, they’re leveraging the
hard work of countless epidemiological studies. This means that their
estimates of years of life lost are based on a robust, unified dataset
that draws from diverse research efforts around the world.

### 4. Actuarial Methods and Life Tables: Measuring the Loss

**What They Are:**  
Actuarial methods, widely used by insurance companies, involve
statistical models to predict future events—in this case, how long
people are likely to live. The primary tool here is the life table, a
chart that follows a hypothetical group of individuals through different
age ranges to determine survival rates.

**Why It’s Critical:**  
By constructing life tables that reflect current (baseline) conditions
and then simulating a “clean air” scenario (where PM2.5-related deaths
are removed), researchers can pinpoint, how many years of life are lost
due to pollution. This method transforms complex data into a tangible
measure: the number of years stolen from our lives by toxic air.

### 5. Exposure-Response Functions

When scientists study how air pollution affects our health, they need a
way to connect the amount of pollution in the air with specific health
problems. This connection is called an “exposure-response function”
(ERF). Think of it as a mathematical formula that answers the question:
“If air pollution increases by a certain amount, how much more likely
are people to experience health problems?”

**How Exposure-Response Functions Work:**

Imagine a graph where the horizontal axis shows the concentration of
tiny air pollution particles (called PM2.5), and the vertical axis shows
the risk of health problems. The line connecting these points is the
exposure-response function.

For example, a real-world ERF might tell us that for every 10 micrograms
per cubic meter increase in PM2.5 pollution, the risk of dying from
heart disease increases by 10%. Researchers need these relationships to
estimate how many years of life are lost due to air pollution.

**Where These Functions Come From:**

Scientists develop these functions by studying large groups of people
over time. For example, the famous Harvard Six Cities Study followed
over 8,000 adults for 14-16 years and found that people living in more
polluted cities died earlier than those in cleaner cities. By analyzing
this data, researchers created exposure-response functions that linked
pollution levels to mortality risk.

**Why They Matter:**

These functions are the foundation for all research connecting air
pollution to life expectancy. Without them, weW couldn’t:

- Estimate how many people die early because of air pollution

- Predict how many lives could be saved by reducing pollution

- Calculate the economic benefits of clean air policies

- Various other outcomes of interest to both policymakers and public

There are different types of proposed ERFs out in the wild and each has
its pros and cons. For the purposes of this blog post, having a big
picture overview of what they are will suffice. But, if you are curious
please do go ahead and dive into this topic, which deserves a separate
blog post of its own.

<br>

## How Life Table Method Reveal the Years of Life Lost Due to Air Pollution

The life table method uses demographic tables (similar to what insurance
companies use) to estimate how much longer people would live if air
pollution were reduced or eliminated. In 2018, Joshua Apte and his
colleagues published a study titled “Ambient PM2.5 Reduces Global and
Regional Life Expectancy” in the journal Environmental Science &
Technology Letters. They calculated how many years of life are lost
globally due to tiny air pollution particles (PM2.5).

**How It Works:**

- Start with tables showing how likely people of different ages are to
  die in a given year

- Calculate what portion of these deaths is caused by air pollution
  (using exposure-response functions)

- Create new tables that remove these pollution-attributable deaths

- Compare the average life expectancy between the real-world tables and
  the pollution-free tables

**Let’s walk through a detailed example, with hypothetical numbers:**

### 1. A Hypothetical Example: Setup

Imagine a hypothetical cohort of **100,000 newborns** in a population
where life expectancy under normal (polluted) conditions is around **70
years**. We’ll track them through standard age intervals to compare two
scenarios: **Baseline scenario:** Current conditions with typical air
pollution levels and **Clean air scenario:** Improved air quality with
reduced PM2.5 exposure. Please note that these are hypothetical numbers
used only for explanation purposes:

**Death Probabilities:**

- **Ages 0–4:**
  - **Baseline death probability (qₓ): 0.005 (0.5%)**
  - **Clean-air death probability: 0.0045 (0.45%)**
- **Ages 5–19:**
  - **Baseline death probability: 0.001 (0.1%)**
  - **Clean-air death probability: 0.0009 (0.09%)**
- **Ages 20–64:**
  - **Baseline death probability: 0.10 (10%)**
  - **Clean-air death probability: 0.095 (9.5%)**
- **Ages 65+:**
  - **Baseline death probability: 0.30 (30%)**
  - **Clean-air death probability: 0.28 (28%)**

### 2. Survivor and Person-Years Calculation

| Age Group | Scenario  | Initial Survivors (lₓ) | Death Probability (qₓ) | Survivors at End (lₓ₊₁) | Average Survivors | Years in Interval | Person-Years (Lₓ) |
|-----------|-----------|------------------------|------------------------|-------------------------|-------------------|-------------------|-------------------|
| 0–4       | Baseline  | 100,000                | 0.005                  | 99,500                  | 99,750            | 5                 | 498,750           |
| 0–4       | Clean Air | 100,000                | 0.0045                 | 99,550                  | 99,775            | 5                 | 498,875           |
| 5–19      | Baseline  | 99,500                 | 0.001                  | 99,400                  | 99,450            | 15                | 1,491,750         |
| 5–19      | Clean Air | 99,550                 | 0.0009                 | 99,460                  | 99,505            | 15                | 1,492,575         |
| 20–64     | Baseline  | 99,400                 | 0.10                   | 89,460                  | 94,430            | 45                | 4,249,350         |
| 20–64     | Clean Air | 99,460                 | 0.095                  | 89,987                  | 94,724            | 45                | 4,262,580         |
| 65+       | Baseline  | 89,460                 | 0.30                   | 62,622                  | 76,041            | 20                | 1,520,820         |
| 65+       | Clean Air | 89,987                 | 0.28                   | 64,791                  | 77,389            | 20                | 1,547,780         |

### 3. Step-by-Step Logic Explained

<u>**Survivor Calculation (lₓ → lₓ₊₁):**</u>

For each age group:

#### $$l_{x+1} = l_x \times (1 - q_x)$$

- In the **0–4 age group** under baseline conditions:

#### $$100,000 \times (1 - 0.005) = 99,500 \text{ survivors}$$

<u>**Person-Years (Lₓ):**</u>

Person-years represent the total years lived by people within an age
group. We calculate this using:

#### $$L_x = \left( \frac{l_x + l_{x+1}}{2} \right) \times \text{Years in Interval}$$

<u>**Average survivors (0–4 baseline):**</u>

#### $$(100,000 + 99,500)/2 = 99,750$$

<u>**Person-years (0–4 baseline):**</u>

#### $$99,750 \times 5 = 498,750$$

<br>

> *Why divide by 2 to calculate average survivors in an age group? We
> assume deaths happen evenly over time, so taking the average number of
> people alive gives a simplified reasonable estimate of total
> person-years contributed across the age interval.*

<br>

### 4. Calculating Life Expectancy (e₀):

Life expectancy at birth is calculated by dividing total person-years
lived by the initial cohort size:

#### $$e_0 = \frac{\text{Total Person-Years}}{\text{Initial Population Size}}$$

<u>**Baseline Scenario:**</u>

#### **Total person-years (sum of all intervals):** $$498,750 + 1,491,750 + 4,249,350 + 1,520,820 = 7,760,670$$

#### $$e_0 = \frac{7,760,670}{100,000} = 77.61 \text{ years}$$

<u>**Clean Air Scenario:**</u>

#### $$498,875 + 1,492,575 + 4,262,580 + 1,547,780 = 7,801,810$$

#### $$e_0 = \frac{7,801,810}{100,000} = 78.02 \text{ years}$$

### 5. What Do These Results Tell Us? (Remember, these are hypothetical numbers only)

The difference in life expectancy:

#### $$78.02 - 77.61 = 0.41 \text{ years}$$

- Each person, on average, loses **0.41 years (~5 months)** of life due
  to air pollution
- Across a population of **1 million people**, this amounts to **410,000
  years** of life lost in total

Although the above example was hypothetical, I hope going through it
gave you a sense of how these calculations are carried out. When you now
read or dive into the literature, hopefully you’ll have a better
appreciation of the results and the actual numbers.

<br>

## Other Research Methods Exploring the Connection between Air Pollution and Health

As I mentioned initially up top, there are various other research
methodologies that aim to shed light on the relationship between air
pollution and life expectancy. Life tables method is one of them, but
there are many others. Each comes with its own strengths and
limitations, but irrespective of the underlying method, one thing is
clear: Air Pollution Kills, this is well established and there is no
denying that. This should always be a given, the specifics come after
this.

Let’s briefly review other research methodologies that we often find in
the air pollution research:

<br>

## Experimental Methods

### Controlled Human Exposure Studies

**What They Are:** These studies bring volunteers into a laboratory
where they breathe air with carefully controlled amounts of pollution.
Researchers then measure immediate changes in their body functions.

**How It Generally Works:**

1.  Recruit healthy volunteers

2.  Have them breathe clean air on one day and polluted air on another
    day

3.  Measure health indicators like blood pressure, heart rate, and
    inflammation

4.  Compare the differences between clean air and polluted air exposure

**Strengths:**

- Shows exactly how pollution affects the body

- Provides stronger evidence that pollution directly causes health
  changes

- Controls for other factors that might affect results

**Limitations:**

- Ethical constraints prevent deliberately exposing people to high
  levels of pollution in studies.
- Long-term effects of pollution cannot be studied in a controlled lab
  setting, as people live in diverse real-world environments.
- Studies often rely on relatively healthy volunteers, which may not
  fully represent the more vulnerable populations most affected by
  pollution**.**

### Animal Studies

**What They Are:** These studies expose laboratory animals (usually mice
or rats) to different levels of air pollution over extended periods to
see how it affects their health.

**How It Generally Works:**

1.  Expose groups of animals to different levels of pollution

2.  Control their diet, housing, and other factors

3.  Monitor their health over time

4.  Examine their organs after death to look for damage

**Strengths:**

- Can expose animals to pollution levels similar to heavily polluted
  cities

- Can study effects over an animal’s entire lifetime

- Can examine internal organs for damage

**Limitations:**

- Animals are not humans, so effects might differ

- Laboratory pollution might differ from real-world pollution

- Ethical concerns about animal testing

<br>

## Quasi-Experimental Methods

### Natural Experiments

**What They Are:** Natural experiments take advantage of unplanned,
real-world events that change air pollution levels, such as factory
closings, strikes, or new regulations.

**How It Generally Works:**

1.  Identify an event that changed pollution levels in some areas but
    not others

2.  Collect health data before and after the event

3.  Compare how health outcomes changed in areas affected by the event
    versus unaffected areas

**Strengths:**

- Examines real-world changes in pollution

- Captures how policies actually work in practice

- Studies effects on real populations, not volunteers

**Limitations:**

- Often limited to specific locations

- Other changes might happen at the same time (like economic changes)

- May not last long enough to capture full health benefits

### **Difference-in-Differences (DiD) Designs**

**What They Are:** A method that estimates the impact of pollution on
health by comparing changes over time between areas with different
pollution trends.

**How It Generally Works:**

- Identify two similar regions—one where pollution levels change due to
  a policy or event and another where they remain relatively stable.

- Measure health outcomes in both regions *before* and *after* the
  pollution change.

- The key idea: If both regions would have followed the same health
  trend in the absence of pollution changes, any *additional* change in
  the affected region can be attributed to pollution.

**Strengths:**

- Accounts for underlying differences between regions by focusing on
  *changes* rather than absolute levels.

- Helps control for factors that affect both areas similarly, such as
  broader economic or healthcare trends.

- Well-suited for evaluating the effects of policies that alter
  pollution levels.

**Limitations:**

- Assumes that, without the pollution change, both regions would have
  had similar health trends (parallel trends assumption).

- Can be less reliable if other major changes (e.g., economic shifts,
  healthcare improvements) affect one region more than the other.

- Requires good-quality data over time for both regions.

### Instrumental Variable (IV) Approaches

**What They Are:** These studies use a third factor (an “instrument”)
that affects pollution levels but doesn’t directly affect health to help
establish cause and effect.

**How It Generally Works:**

1.  Find something that changes pollution levels but doesn’t directly
    affect health

2.  Use this factor to predict pollution levels

3.  Examine how these predicted pollution levels relate to health
    outcomes

Think of it like this: If more people get sick on days when the wind
blows from a factory toward a town (compared to days when it blows away
from the town), the factory’s pollution is likely causing the health
problems.

**Strengths:**

- Helps establish that pollution actually causes health problems (if the
  instrument is valid)

- Controls for factors that might confound the relationship

- Can work even when pollution measurement isn’t perfect

**Limitations:**

- Requires finding a good “instrument” that affects pollution but not
  health directly

- Often focuses on short-term rather than lifetime effects

- Can be statistically complex

### Regression Discontinuity Designs

**What They Are:** These studies look at sharp boundaries where
pollution levels or regulations change abruptly to detect health
effects.

**How It Generally Works:**

1.  Find a threshold where something changes sharply (like a regulatory
    boundary)

2.  Compare health outcomes just above and below this threshold

3.  Assume that people just above and below the threshold are similar
    except for their exposure to the factor being studied

For example, if a regulation applies to cities above 100,000 population
but not smaller cities, comparing health in cities of 99,000 people
versus 101,000 people can show the regulation’s effects.

**Strengths:**

- Provides strong evidence of causal effects near the threshold

- Controls for many factors that might affect results

- Can measure direct effects of specific policies

**Limitations:**

- Results may only apply to areas near the threshold

- Requires a clear, sharp boundary to study

- May not have enough data points near the threshold

<br>

## Longitudinal Cohort Studies

**What They Are:** These studies follow large groups of people over many
years, measuring their exposure to pollution and tracking their health
outcomes.

**How It Generally Works:**

1.  Recruit thousands or even millions of people

2.  Collect information about where they live, their lifestyle, and
    other factors

3.  Estimate their exposure to air pollution based on their location

4.  Follow them for years or decades, recording who gets sick or dies

5.  Analyze whether those with higher pollution exposure had worse
    health outcomes

**Strengths:**

- Follows real people over time

- Can control for individual factors like smoking, diet, and exercise

- Directly measures the relationship between pollution and lifespan

**Limitations:**

- Very expensive and time-consuming to conduct

- People may move to different areas with different pollution levels

- People who agree to participate may not represent the general
  population

<br>

## Other Methodological Innovations

### Causal Inference Statistical Methods

**What They Are:** These are advanced statistical techniques designed to
further strengthen our ability to determine whether pollution actually
causes health problems, rather than just being associated with them.

**How It Generally Works:**

1.  Use mathematical frameworks to clarify what factors might influence
    both pollution levels and health

2.  Apply statistical methods to account for these factors

3.  Use sensitivity analyses to test whether results hold under
    different assumptions

For instance, these methods might help determine whether people in
polluted areas die earlier because of the pollution itself or because
polluted areas tend to have more poverty (which also affects health).

**Strengths:**

- Provides stronger evidence for causal relationships

- Accounts for uncertainty in pollution measurements

- Tests whether results are sensitive to hidden factors

**Limitations:**

- Mathematically complex and difficult to explain

- May require assumptions that are hard to verify

- Might often requires more data than simpler approaches

### High-Resolution Exposure Assessment

**What They Are:** These are improved methods for estimating how much
pollution each person is actually exposed to, using satellites, computer
models, and monitoring networks.

**How It Generally Works:**

1.  Combine data from ground-level pollution monitors

2.  Add satellite measurements that can see pollution from space

3.  Use weather models and information about land use

4.  Apply machine learning to predict pollution levels where no monitors
    exist

**Strengths:**

- Provides more accurate estimates of individual exposure

- Can identify pollution “hotspots” within cities

- Allows research in areas without monitoring stations

**Limitations:**

- Requires complex modeling and computing power

- May still miss important variations in personal exposure

- Historical data limitations prevent application to past decades

<br>

## Bringing It All Together

Each of these research methods offers a different piece of the puzzle
about how air pollution affects our lifespan:

1.  **Life table methods** (like Apte’s study) provide big-picture
    estimates of how many years of life are lost globally.

2.  **Experimental methods** show us the biological mechanisms by which
    pollution harms our bodies.

3.  **Quasi-experimental methods further** provide even stronger
    evidence that pollution actually causes shorter lives, not just that
    the two are correlated.

4.  **Cohort studies** directly observe the relationship between
    pollution exposure and lifespan in real populations over time.

5.  **New methodological innovations** improve the accuracy and
    reliability of all these approaches.

<br>

> ***The strongest evidence comes from when multiple methods with
> different strengths and limitations all point to the same conclusion:
> that air pollution significantly reduces life expectancy worldwide.
> This is where all current evidence irrespective of the underlying
> research method points, that is the one key take away I want you to
> have.***

<br>

## Real-World Implications

This research has profound implications for public policy. For example:

- Various governments across the world use this evidence to set air
  quality standards

- The World Health Organization develops air quality guidelines based on
  this evidence

- Cities and countries design clean air policies based on projected life
  expectancy benefits

- Researchers calculate the economic benefits of pollution reduction by
  valuing these added years of life

By understanding how much longer people would live with cleaner air,
policymakers can make more informed decisions about environmental
regulations, transportation systems, energy policies, and public health
initiatives.

<br>

## Conclusion

Air pollution isn’t a minor inconvenience—it’s an immediate threat
that’s literally stealing years from our lives. Through rigorous methods
of various types, researchers have demonstrated that PM2.5 is
responsible for a significant loss of life expectancy. The detailed math
example in the post shows how, by comparing current conditions with a
hypothetical “clean air” scenario, we can quantify the human cost in
terms of years lost.

Other research approaches—whether tracking individual health outcomes
over decades, analyzing the immediate effects of policy changes, or
comparing regions with different pollution levels—all lead to the same
conclusion: every moment we delay action, more lives are cut short. The
math, the models, and the hard data all point to one fact: we must act
now to reduce air pollution and protect our future.

This isn’t a debate or an academic exercise—it’s a call to immediate
action. Every fraction of a year we gain by reducing PM2.5 is a victory
against a deadly enemy. It’s time to take the science seriously and work
together to secure a healthier, longer future for everyone.

<br>

## Rmd for this blog

The underlying Rmd for this blog post can be found
[here](https://github.com/AarshBatra/biteSizedAQ/blob/main/11.air.pol.life.exp.calc.apte.other.methods/README.Rmd).

<br>

## Support This Work: Give It a Star

Thank you for reading! If you found this project helpful or interesting,
please consider starring it on GitHub. Your stars help others discover
and benefit from this fully open and free repository. Click [here to
star the
repository](https://github.com/AarshBatra/biteSizedAQ/stargazers) and
join other folks who follow biteSizedAQ.

<br>  
  
![](images/clipboard-526920622.png)

<br>

## Get in touch

Get in touch about related topics/report any errors. Reach out to me at
bitesizedaq@gmail.com.

<br>

## License and Reuse

All content is shared under the Creative Commons Attribution 4.0
International (CC BY 4.0) license. You are welcome to use this material
in your reports or news stories. Just remember to give appropriate
credit and include a link back to the original work. Thank you for
respecting these terms!

For more details, see the LICENSE file.

If you use this in your work, please cite this repository as follows:  
*\[Aarsh Batra, biteSizedAQ,
<https://github.com/AarshBatra/biteSizedAQ>\]*
