---
title: "Bayesian Optimization: A New Sample Efficient Workflow for Reservoir Optimization under Uncertainty"
author:
  - name: "Peyman Kor"
#    email: "peyman.kor@uis.no"
    affiliation: a
    footnote: 1
  - name: Aojie Hong
#    email: "aojie.hong@uis.no"
    affiliation: a
  - name: Reidar Brumer Bratvold
#    email: "reidar.bratvold.uis.no"
    affiliation: a
address:
  - code: a
    address: Energy Resources Department, University of Stavanger, Stavanger, Norway
footnote:
  - code: 1
    text: "Corresponding Author, peyman.kor@uis.no"
#  - code: 2
#    text: "Equal contribution"
abstract: |
 \doublespacing An underlying challenge in well-control optimization during field development is that flow simulation of a 3D, full physics grid-based model is computationally prohibitive. In a robust optimization setting, where flow simulation has to be repeated over a hundred(s) of geological realizations, performing a proper optimization workflow becomes impractical in many real-world cases. In this work, to alleviate this computational burden, a new sample-efficient optimization method is presented. In this context, sample efficiency means that the workflow needs a minimum number of forward model evaluations (flow-simulation in the case of reservoir optimization) while still being able to capture the global optimum of the objective function. Moreover, the workflow is appropriate for cases where precise analytical expression of the objective function is nonexistent. Such situations typically arise when the objective function is computed as the result of solving a large number of PDE(s), such as in reservoir-flow simulation. In this workflow, referred to as ``Bayesian Optimization'' the objective function for samples of decision variables is first computed using a proper design experiment. Then, a Gaussian Process (GP) is trained to mimic the surface of the objective function as a surrogate model. While balancing the exploration-exploitation dilemma, a new decision variable is queried from the surrogate model and a flow simulation is run for this query point. Later, the output of the flow-simulation is assimilated back to the surrogate model which is updated given the new data point. This process continues sequentially until termination criteria are reached. To validate the workflow and get better insight into the details of optimization steps, we first optimize a 1D problem. Then, the workflow is implemented for a 3D synthetic reservoir model in order to perform robust optimization in a realistic field scenario. Finally, a comparison of the workflow with two other commonly used algorithms in the literature, namely Particle Swarm Intelligence (PSO) and Genetic Algorithm (GA) is performed. The comparison shows that the workflow presented here will reach the same near-optimal solution achieved with GA and PSO, yet reduce computational time of the optimization 5X (times). We conclude that the method presented here significantly speeds up the optimization process leveraging a faster workflow for real-world 3D optimization tasks, potentially reducing CPU times by days or months, yet gives robust results that lead to a near-optimal solution. 
journal: "Journal of Petroleum Science And Engineering"
geometry: margin=1in
header-includes:
  - \usepackage{setspace}
date: "2021-09-09"
bibliography: [references.bib]
linenumbers: true
numbersections: true
keywords: "Optimization, Gaussian Process, Probabilistic Modeling, Bayesian"
csl: elsevier-harvard.csl
#output: rticles::elsevier_article
#output: officedown::rdocx_document
output:
  bookdown::pdf_book:
    base_format: rticles::elsevier_article
    keep_md: true
number_sections: true
fig_caption: yes
#   rticles::elsevier_article: default
#   word_document: default
# output:
#   bookdown::word_document2:
#     base_format: rticles::elsevier_article
  
#output:
#  bookdown::pdf_document2:
#    fig_caption: yes
editor_options: 
  markdown: 
    wrap: 72
---



\newpage



# Introduction:

\doublespacing

Well control optimization (also known as production optimization) can be defined as making the best decision for a set of control variables in continuous space, given a pre-defined objective function. The objective function generally relies on a reservoir simulator to evaluate the proposed well control decision for the period of the reservoir life cycle. On the other hand, the control decisions are usually well injection/production rates or bottom-hole pressure (BHPs). Given the objective function and alternatives, uncertainties are represented by a set of geological realizations (i.e., an ensemble). Known, as Robust Optimization (RO), within RO, the objective is to find a control vector to maximize the expected value of the objective function over geological uncertainty in contrast to deterministic case, where the sources of uncertainty in geological model is ignored. Well control optimization typically poses challenges as the objective function is non-linear and non-convex. Moreover, the optimization problem becomes computationally demanding in the RO setting as many geological models must be considered. This renders the optimization computationally expensive, if not prohibitive, in large-scale systems where (potentially) hundreds of wells are involved.

Literature of well control optimization can be viewed from two angles. At first, the focus is on the type of optimization algorithm used for this type of problem. Broadly speaking, the type of optimization algorithm could be divided into two categories, gradient-based and gradient-free.

[@sarma2005] applied adjoint-gradient based optimization to waterflooding problem. [@vanessen2009] optimized hydrocarbon production under geological uncertainty (in RO setting), where an adjoint-based method is used for obtaining the gradient information. The adjoint-based procedure is more efficient because it uses gradients that are constructed efficiently from the underlying simulator. However, the adjoint-based method requires access to the source code of the reservoir simulator, which is seldom available for commercial simulators, and it is computationally intensive. @chen2009 introduced the ensemble-based optimization method (EnOpt), in which the gradient is approximated by the covariance between the objective function values and the control variables. @do2013 analyzed the theoretical connections between EnOpt and other approximate gradient-based optimization methods. Having realized that it is unnecessary to approximate the ensemble mean to the sample mean as was done by @chen2009, @do2013 used the ensemble mean in their EnOpt formulation. @stordal2016 had a theoretical look at EnOpt formulation and showed that EnOpt is a special case of well-defined natural evolution strategy known as Gaussian Mutation. It is a special case from this perspective that EnOpt is Gaussian Mutation without the evolution of covariance matrix $(\sum)$ of multivariate Gaussian density.

On the other hand, gradient-free methods represent a useful alternative when gradients are not available or are too expensive to compute. It can be divided into two major classes, stochastic and pattern search; these methods are noninvasive with respect to the simulator, though they are usually less efficient and require a larger number of function evaluations than adjoint-gradient methods.

Probably the first use of the gradient-free method for subsurface application, [@harding1998] applied genetic algorithm (GA) to production scheduling of linked oil and gas fields. A Comparison study was performed, and they showed the GA outperforms simulated annealing (SA) and sequential quadratic programming (SQP) techniques, and a hybrid of the two. GA was utilized later by [@almeida2007] for the optimization of control valves in the intelligent wells. They found that significant profit was achieved in comparison to using conventional methods (no valve control). More recently, [@lushpeev2018] applied Particle Swarm Optimization (PSO) to a real field case to find optimum injection mode for the mature field. Control variables were the change in injection rates of 3 injectors, and results of field experiments show the improvement in relative recovery after applying the modified solution of the optimization algorithm.

Generalized Pattern-search (GPS) methods [@torczon1997; @dennis] are another types of gradient-free techniques has been applied in well control optimization problem. The pattern-search method relies on polling; a stencil is centered at the current solution at any particular iteration. The stencil comprises a set of directions such that at least one is a descent direction. If some of the points in the stencil represent an improvement in the objective function, the stencil is moved to one of these new solutions. GPS, including its variant (Mesh Adaptive Direct Search), is usually considered a local search method, but due to its ability to parallelize, it has been well used in the literature of well control optimization. [@echeverríaciaurri2010; @asadollahi2014; @foroud2016; @nwachukwu2018]. To overcome the locality of the GPS methods, hybrid of the PSO as global method and then using pattern search for local search in iterative (PSO-MADS) way as well proposed in the work of [@isebor2013; @debrito2020].

## Survey of surrogate-based papers in Onepetro database

In the previous section, we reviewed commonly used optimization algorithms in well control optimization. However, it should be noted that even with a more efficient optimization method like EnOpt, still performing full RO optimization with full physic reservoir simulators is computationally prohibitive (we will discuss the detail of this computational burden more in Section 2) [@hong2017]. In order to make RO feasible, two general approaches have been introduced. The first set of techniques targets the flow problem. These methods include capacitance-resistance models [@hong2017; @yousef2006; @zhao2015], deep-learning and machine learning surrogates [@kim2021; @nwachukwu2018; @kim2020; @chai2021] and reduced-physics simulations [@debrito2020; @nasir2021; @møyner2014]. These methods generally entail approximating the high-fidelity flow simulation model with a lower-fidelity or reduced order model, or a model based on simplified flow physics. To get insight into how this line of research is evolving, we performed a small text mining task. Mining the more than 100000 peer-reviewed papers published in (www.onepetro.org), we count the number of the papers with "one" of the following keywords in their abstract:

1.  "Proxy" + " Optimization" + "Reservoir"
2.  "Surrogate" + "Optimization" + " Reservoir"
3.  "Reduced-physics model" + "Optimization" + " Reservoir"

The period of 1995-2020 was considered. As Figure \@ref(fig:onepetroanalysis) reveals, we see that just around ten years ago in this research area we had around \~ 10 papers per year, now that number is around three times more. Part of this interest in developing a "physic-reduced model" could be attributed to development in machine learning research and transferring knowledge for building data-driven models for subsurface applications.

\begin{figure}

{\centering \includegraphics[width=468px]{0_Paper1_main_files/figure-latex/onepetroanalysis-1} 

}

\caption{Counting the number of papers with the keyword in their abstract vs year}(\#fig:onepetroanalysis)
\end{figure}

In this work, we propose Bayesian Optimization (BO). We will show that BO, as a gradient-free method, has characteristics of the global optimization method in escaping local optima or saddle area. While, at the same time, the workflow overcomes the typical downside of gradient-free methods, which is need for many function evaluations. Due to utilizing the probabilistic model to mimic the expensive objective function, BO workflow is inherently efficient, meaning that a minimum number of function evaluations is needed to achieve a near-optimum solution. To validate this idea, we compared the BO with two other gradient-free, global optimization techniques (PSO, GA) while showing BO reaches similar (same) solutions while using only 20% of function evaluations, compared to the other two algorithms. We would like to refer to the results of the "OLYMPUS Optimization Benchmark Challenge" [@fonseca2020] where the gradient-free methods showed the best performance in achieving the highest NPV, but participants mentioned the pain of these methods as they carry huge computational burden due to large function evaluation [@silva2020; @pinto2020; @chang2020]. In light of benchmark results, bringing the efficiency to the gradient-free optimization category is a significant contribution, presented in this work.

In Section 2 ("Problem Statement"), we will describe the underlying problem in well control optimization and the need for efficient optimization to deal with the enormous computational burden of optimization. In Section 3 ("Bayesian Optimization Workflow"), we will lay out the mathematical background of the BO workflow. In section 4, "Examples Cases", BO workflow is applied to two numerical cases. The first one is a 1-D example where we guide our audience with a step-by-step process about applying BO. The second numerical example is the field case. Where BO is applied to a 3-D synthetic geological model for optimizing injection scheme in eight injectors. In section 5, "Comparison with other Alternatives", a comparison of the BO with two global optimization techniques, PSO and GA, is presented. The paper ends with "Concluding Remarks" in section 6.

<!-- -   small function value f(x) with least search cost there are two conflicting objectives -->

<!-- -   Global Optimiation [\^1] -->

<!-- While developing a field, prediction of reservoir response to change in the variable is an am important factor to have an efficient reservoir management. The field of reservoir engineering is rich in the development and application of full-physics numerical simulations for forward modeling. However, the computational power needed to run such numerical simulators most of the time is huge. Especially, the framework of the Robust Optimization where uncertainty are considered through multiple of geological realization (thousand or multi-thousand), the practical applicability of such forward modeling is considerably limited. To address this challenge, the proxy-modeling for reservoir managemnet has emerged to reduce the cost of forward simulation. The root of this field goes back to the work of the [@bruce1943] where the analogy between flow of electricty in tthorugh te electrical device and the response of the reservoir was constructed. [@albertoni2003] Proposed the a Multivariate Linear Regression (MLR) to estimate the production from the well, where it claimed that total production at each is linear combination of injection rates with diffusitivity filter. Building on the work of [@albertoni2003], [@yousef2006] proposed a new procedure to quantify communication between wells, where for each injector/producer pair, two coefficients, capacitance to quantify connectivity and time constant to quantify the degree of fluid storage were considered. [@sayarpour2008] used superposition in time to analytically solve the numerical integration in CRM. [@zhao2015](Zhao et al. 2015) articulated that CRM models are not applicable when production rates change significantly, mainly due to those models neglect to include intearction of production-production and injector-injector pair well. Formulating the model in the framework titled INSIM (interwell numerical simulation model), it was used as efficient replacement to reservoir simulator when history-matching phase rate data or water-cut data obtained during water flooding operations. -->

<!-- Seperatley, in sake of utilization of recent advancemnet in the world of Information technology, couple of reaserach has been don eon the development of "Surrogate Reservoir Models" - [@mohaghegh2006] proposed the workflow for SRM model where Fuzzy Paatern Recognition (FPR) technology was dimensionality reduction, in both static and dynamic parameters of the reservir . Key Performance Indicator (KPI) was used to select the most important variable.- [@sampaio2009] tried on use of feed-forward neural networks as nonlinear proxies of reservoir response. A few set of rock and fluid properties were considere a input (porosity, permeability in "x" direction, permeability in "y" direction, and rock compressibility) where in developing the neural network model, only one hidden layer was used. flow proxy modeling to replace full simulation in history matching, and built the proxy with a single hidden layer artificial neural network (ANN). To predict the oil production from the SAGD rocess, (Fedutenko et al. 2014) [@fedutenko2014]employed the RBF Neural Network to predict the cumulative oil production over the time horizon of production (10 years) . <!--#  -->

\newpage


# Problem Statement

In general, an optimization task can be defined as a search process for the maximum output value of a "well behaved" [^1] objective function $f$. Can be defined as $f: \chi \rightarrow \mathbb{R}$ where acceptable solutions $\chi$, has a dimension of $D$, $\chi \subseteq \mathbb{R}^D$ :

[^1]: In this context, it means the function is defined everywhere inside the input domain, it is single-valued and continuous.

```{=tex}
\begin{equation}
\begin{aligned}
& \underset{x}{\text{maximize}}
& & f(x) \\
& \text{subject to}
& & x \subseteq \chi
\end{aligned}
\label{eq:globalopt}
\end{equation}
```

In Figure \@ref(fig:optglobal) we can see some examples where the surface of $f$ could be challenging to be optimized. The surfaces on the left side need careful attention to avoid getting stuck in local optima. Figures on the right side show presence of saddle area, where the gradient of function $f$ is zero, in some cases in only one direction, possibly all directions. In this work, the focus is on the type of objective function $f$, which is challenging to optimize because of the following three difficulties:

-   $f$ is explicitly unknown. This is a typical case in reservoir optimization problems where the Net Present Value (NPV) or Recovery Factor (RF) is computed through solving a vast number of partial differential equations through flow simulation. Thus, a precise analytical expression for the objective function is not available, avoiding the applicability of techniques that exploit the analytical expression of the objective function.
-   The surface of $f$ is multi-modal. Meaning that $f$ is non-convex in the domain of $\chi$ , and the optimization algorithm must visit all local optima to find the "global" one.
-   Most importantly, forward evaluation of $f$ is computationally expensive. This point will be discussed more in detail below.

\begin{figure}

{\centering \includegraphics[width=0.7\linewidth]{img/globalopt} 

}

\caption{This plot may change, it does not show what exactly I want to say...}(\#fig:optglobal)
\end{figure}

In the examples of this paper, the goal is to maximize the subsurface-outcomes-based NPV (in USD). Thus, the primary objective function is also referred to as simply NPV in the rest of this paper. This objective function has been widely used in both well control and field development optimization studies. In a deterministic setting, the uncertainty in the geological parameters is disregarded and the optimization is performed based on a single geological model. Therefore, in the case of deterministic optimization, the objective function can be defined as:

```{=tex}
\begin{equation}
J(\mathbf{u, G})= \sum_{k=1}^{K} \Bigg [\sum_{j=1}^{N_p}p_oq_{o,j,k}(\mathbf{u, G}) 
- \sum_{j=1}^{N_p}p_{wp}q_{wp,j,k}(\mathbf{u, G}) - 
\sum_{j=1}^{N_{wi}}p_{wi}q_{wi,j,k}(\mathbf{u, G}) \Bigg]\frac{\Delta t_k}{(1+b)^{\frac{t_k}{D}}}
\label{eq:npvdet}
\end{equation}
```

Where the first term in the double summation corresponds to the oil revenue; the second term is water-production cost and third term corresponds to the water-injection cost. Equation \@ref(eq:npvdet) is considered as objective function in the deterministic setting since only a single geological model is considered. The $G$ in the Equation \@ref(eq:npvdet) is "the geological model". The additional parameters in the Equation are as follows: $K$ is the total number of timesteps; $N_p$ is the total number of production wells subject to optimization; $N_{wi}$ is the total number of water-injection wells subject to optimization; $k$ is the timestep index; $j$ is the well-number index; $p_o$ is the revenue from oil production per unit volume (in USD/bbl); $p_{wp}$ is the water-production cost per unit volume (in USD/bbl); $p_{wi}$ is the water-injection cost per unit volume (in USD/bbl); $q_o$ is the oil-production rate (in B/D); $q_{wp}$ is the water-production rate (in B/D); $q_{wi}$ is the water-injection rate (in B/D); $\Delta t_k$ is the time interval for timestep $k$ (in days); $b$ is the discount rate (dimensionless); $t_k$ is the cumulative time for discounting; and D is the reference time for discounting ($D = 365$ days if b is expressed as a fraction per year and the cash flow is discounted daily). $\mathbf{u}$ in Equation \@ref(eq:npvdet) is the control vector (i.e., a vector of control variables) defined as $\mathbf{u} = [u_1, u_2, \cdots, u_N]^D$, where $D$ is the number of control variables (dimension of optimization problem).

As mentioned above, Equation \@ref(eq:npvdet) lacks to capture the uncertainty in the geological model. In contrast, in a Robust Optimization (RO) setting, the objective is to optimize the expected value over all geological realizations (assumption here is decision maker is risk-neutral). The objective function for the RO setting then can be defined as: (in the case of equiprobable geological realization)

```{=tex}
\begin{equation}
\overline{J}(\mathbf{u}) = \frac{\sum_{re=1}^{n_e} J(\mathbf{u,G_{re}})}{n_e}
\label{eq:npvopt}
\end{equation}
```
Where in Equation \@ref(eq:npvopt) contrary to Equation \@ref(eq:npvdet), there is not one, rather $n_e$ geological realizations, each of them written as $G_{re}$. In this work, the objective is to optimize the Equation \@ref(eq:npvopt), where it is simply EV value of NPV defined in \@ref(eq:npvdet) over all realizations.\

It is well defined in the literature that optimizing Equation \@ref(eq:npvopt) is computationally prohibitive [@debrito2021; @nwachukwu2018; @hong2017]. Not only because thousand(s) of PDE have to be solved in the flow-simulation in order to compute the $q_o, q_{wp}, q_{wi}$; the flow simulation must be enumerated over all realizations $n_e$ to compute $\overline{J}(u)$. Let's assume a simple case to illustrate the computational burden of this optimization problem. Assume that an E&P enterprise is in the process of finding the bottom hole pressure of five injection wells and shut-in time of other five production wells, $D=10$. The geology team of the enterprise comes up with 100 geological realizations of the model.($n_e=100$). Now, if we suppose that the reservoir model is 3D with a moderate number of grid cells, it is not hard to imagine that flow-simulation of a fine grid model will take \~1hr. Then, simply having 100 realizations means that each forward computation of $\overline{J}(u)$ takes around \~100 hr. Considering that the enterprise has to decide in 6 month period (in the best case, it can be interpreted as 6 months CPU running time), which means that a total number of the available budget for running the forward model is$\frac{6 \times 30 \times 24 }{100}= 43.2 \approx 50$ is around 50. The budget of only $50$ forward model in ten-dimensional, non-linear, and non-convex optimization problem is relatively low. To put this in simple terms, if we say that each dimension of the control variable $\mathbf{u}$, could be discretized into ten possible cases, then total available solutions for this optimization problem will be $\text {Number of all possible solutions} = 10^{10}$. As it is clear, finding the best solution from a pool of ten billion possible solutions with only 50 shots is a pretty much hard undertaking.\

The rest of this paper will be arguing that the Bayesian Optimization workflow is well suited to deal with the three difficulties described above. Where the workflow needs to capture the optimum global point (area) while having a small forward evaluation budget.

\newpage






# Bayesian Optimization Workflow

## Overall View

Bayesian Optimization (BO) is an optimization method that builds a probabilistic model to mimic an expensive objection function. The probabilistic model is an inference from a finite number of function evaluations. This finite number of evaluations is done as initialization of the workflow and build a probabilistic model.

After initializing and building a probabilistic model, a new query point is evaluated using the expensive objective function at each iteration. Then the new data $(\mathbf{u}^{new},\mathbf{J}(\mathbf{u}^{new}))$ is assimilated back to the probabilistic model to update the model. The unique methodology of using a non-deterministic surrogate model makes Bayesian optimization (BO) an efficient global optimizer capable of exploring and exploiting space of decision.

In the rest of this section, the objective function is shown with $\overline{\mathbf{J}}(\mathbf{u})$, consistent with the Equation \@ref(eq:npvopt). However, for convention, we drop the bar and write the $\overline{\mathbf{J}}(\mathbf{u})$ with $\mathbf{J}(\mathbf{u})$. Moreover, $\mathbf{u}$ is a control decision, with a dimension of $D$, $\mathbf{u}=[u_1,\cdots,u_D]$. While, the capital letter, $\mathbf{U}$ is collection of $\mathbf{N}$ points of $\mathbf{u}$, defined as: $\mathbf{U}= [\mathbf{u_1},\cdots,\mathbf{u_N}]$.

The workflow of BO can be divided into two steps:

-   Step 1: Choose some initial design points $\mathcal{D}=\{{\mathbf{U},\mathbf{J(U)}}\}$ to build a probabilistic model inferred from $\mathcal{D}$
-   Step 2: Deciding on next $\mathbf{u}^{next}$ and evaluate $\mathbf{J(u^{next})}$ based on probabilistic model and $\mathcal{D}=\mathcal{D}\: \cup[\mathbf{u}^{next},\mathbf{J(u^{next})}]$

After step 2, we come back to step 1 with the new $\mathcal{D}$, and we iterate this process until we are out of computational budget. First, we will explain Gaussian Process (GP) as a method for building a probabilistic model as a background for the workflow. Then, both steps are explained in detail.

## Gaussian Process

In this work, we employ the widely used Gaussian process (GP) as a probabilistic model. Known as a surrogate model (since it tries to mimic the real, expensive objective function), GP is an attractive choice because it is computationally traceable with the capability to quantify the uncertainty of interest [@rasmussen2006; @murphy2022]. A GP can be seen as an extension of the Gaussian distribution to the functional space. Key assumption in (GP) is that: the function values at a set of $M > 0$ inputs, $\mathbf{J} = [\mathbf{J({u_1})}, ...,\mathbf{J(u_M)}]$, is jointly Gaussian, with mean and Covariance defined as:

```{=tex}
\begin{equation}
  \begin{split}
& \mathbb{E} \: [\mathbf{J(u)}]= m(\mathbf{u}) \\
& \text{Cov} \: [\mathbf{J(u)}),J(\mathbf{J(u')}]= \kappa(\mathbf{u},\mathbf{u'})
  \end{split}
\label{eq:mean-cov}
\end{equation}
```

In \@ref(eq:mean-cov), $m(\mathbf{u})$ is a mean function and $\kappa(\mathbf{u},\mathbf{u'})$ is a covariance function (or kernel). $\kappa(\mathbf{u},\mathbf{u'})$ specifies the similarity between two values of a function evaluated on $\mathbf{u}$, and $\mathbf{u'}$ . A GP is a distribution over function completely defined by its mean and covariance function as:

```{=tex}
\begin{equation}
J(\mathbf{u}) \sim \mathcal{N}(m(\mathbf{u}), \kappa(\mathbf{u},\mathbf{u'}))
\label{eq:mean_cov_gp}
\end{equation}
```

where $\mathcal{N}$ denotes a multivariate normal distribution.As discussed in [@shahriari2016], there are many choices for the covariance function; the most commonly used ones in the literature have been depicted in Table \@ref(tab:cov-tab).

\begin{table}[H]

\caption{(\#tab:cov-tab) Several types of covariance function for the GP process}
\centering
\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\toprule
Covariance Kernels & assumeing $h=||u-u'||$\\
\midrule
Gaussain & $\Large \kappa (\mathbf{u},\mathbf{u'}) =\sigma_f^2 exp(-\frac{h^2}{2\ell^2})$\\
Matern $\nu=\frac{5}{2}$ & $\Large \kappa (\mathbf{u},\mathbf{u'}) =\sigma_f^2(1 + \frac{\sqrt{5}|h|}{\ell}\frac{5h^2}{3\ell^2})exp(-\frac{ -\sqrt{5}|h|}{\ell})$\\
Matern $\nu=\frac{3}{2}$ & $\Large \kappa (\mathbf{u},\mathbf{u'}) =\sigma_f^2(1 + \frac{\sqrt{3}|h|}{\ell})exp(-\frac{-\sqrt{3}|h|}{\ell})$\\
Exponetial & $\Large \kappa (\mathbf{u},\mathbf{u'}) =\sigma_f^2 exp(-\frac{|h|}{\ell})$\\
Power-Exponetial & $\Large \kappa (\mathbf{u},\mathbf{u'}) =\sigma_f^2 exp(-(\frac{|h|}{\ell})^p)$\\
\bottomrule
\end{tabu}
\end{table}

Where in the Table \@ref(tab:cov-tab), $\ell$ is length-scale, and $h$ is eludian distance of $\mathbf{u}$, $\mathbf{u'}$. ( Note that $|h|^2=(\mathbf{u}-\mathbf{u'})^\intercal(\mathbf{u}-\mathbf{u'})$). In this work, the Matern covariance function with $\nu=\frac{5}{2}$ was employed. However, depending to any choice of covariance function, the parameters of covariance function needs to be estimated. These parameters can be denoted as $\theta$ as:

```{=tex}
\begin{equation}
\theta = [\sigma^2_{f},\ell]
\label{eq:cova-theta}
\end{equation}
```

The parameter $\theta$ needs to be optimized, as it will be explained later. With this background, BO workflow is explained as follows.

### Step 1: Choose some initial design points $\mathcal{D}=\{{\mathbf{U},\mathbf{J(U)}}\}$ to build probabilistic model inferred from $\mathcal{D}$

Assuming we start GP with a finite number of an initial evaluation of $\mathbf{J(u)}$ on the points in $\mathbf{U}$, we can define the data-set $\mathcal{D}$ as:

```{=tex}
\begin{align}
  \begin{split}
\mathbf{U}= & \: [\mathbf{u_1},\cdots,\mathbf{u_N}] \\
\mathbf{J_U}= & \: [\mathbf{J(u_1)},\cdots,\mathbf{J(u_N)}] \\
\mathcal{D}= & \: \{\mathbf{U},\mathbf{\mathbf{J_U}}\}
  \end{split}
\label{eq:init-data}
\end{align}
```

Now we consider the case of predicting the outputs for new inputs that are not in $\mathcal{D}$. Specifically, given a test set (prediction set) set $\mathbf{U_*}$ of size $\mathbf{N_* \times D}$, we want to predict the function outputs $\mathbf{J_{U_*}} = [\mathbf{J(u_1)},\cdots, \mathbf{J(u_{N_*})}]$. By definition of the GP, the joint distribution $p(\mathbf{J_U}, \mathbf{J_{U_*}})$ has the following form:

```{=tex}
\begin{equation}
\begin{bmatrix}  {\bf {J_U}}  \\  {\mathbf{J_{U_*}}} \end{bmatrix} \sim \mathcal{N} \begin{pmatrix} \begin{bmatrix}  {m(\mathbf{U})}  \\  {m(\mathbf{U_*})} \end{bmatrix},\begin{bmatrix} {{\bf K}_{U,U}}  & {{\bf
K}_{U,U_*}}  \\  {{\bf \mathbf{K}^\intercal}_{U,U_*}} & {{\bf K}_{U_*,U_*} } \end{bmatrix}\end{pmatrix}
\label{eq:gp-model-mat}
\end{equation}
```

Where, $m(\mathbf{U})$ is prior knowledge about mean value of $\mathbf{J_U}$, defined as $m(\mathbf{U})=[m(\mathbf{u_1}),\cdots,m(\mathbf{u_N})]$. For simplicity someone can assume the prior mean function to be zero: $m(\mathbf{U}) = 0$. This assumption is not restrictive because as more training points are observed the prior is updated and becomes more informative. In this work, we considered the case where the mean function could have a linear trend in the form of:

```{=tex}
\begin{equation}
m(\mathbf{u}) = \sum_{j=1}^p \beta_j \mathbf{u}
\label{eq:linear-mean}
\end{equation}
```

The *Gram* matrix, $\mathbf{K}_{U,U}$, is $\mathbf{N \times N}$ matrix, with each element is covariance of $\mathbf{u}$ and $\mathbf{u'}$:

```{=tex}
\begin{equation}
\mathbf{K}_{U,U}=\kappa(\mathbf{U,U})=\left (
\begin{array}{ccc}
\begin{array}{l}
\kappa(\mathbf{u_1},\mathbf{u_2})
\end{array}
& \cdots & 
\begin{array}{l}
\kappa(\mathbf{u_1},\mathbf{u_N})
\end{array} \\
\vdots & \ddots & \vdots\\
\begin{array}{l}
\kappa(\mathbf{u_N},\mathbf{u_1})
\end{array} &
\cdots & 
\begin{array}{l}
\kappa(\mathbf{u_N},\mathbf{u_N})
\end{array} 
\end{array}
\right )
\label{eq:kernel_struct}
\end{equation}
```

By the standard rules for conditioning multivariate Gaussian distribution, we can drive the posterior (conditional distribution of $\mathbf{J_{U_*}}$ given the $\mathcal{D}$) in closed form as follows:

```{=tex}
\begin{align}
  \begin{split}
p(\mathbf{J_{U_*}}|\mathbf{\mathcal{D},\theta)}= & \:  \mathcal{MN}(\mathbf{J_{U_*}| \mathbf{\mu_*},\textstyle \sum_{\ast}}) \\
{\mathbf{\mu_\ast}}= & \:  m(\mathbf{U_\ast}) +\mathbf{K}^\intercal_{U,U_*} \mathbf{K}^{-1}_{U,U}(\mathbf{J_U}-m(\mathbf{U})) \\
\textstyle \sum_{\ast}=& \:  \normalsize{\mathbf{K}_{U_\ast,U_\ast}-\mathbf{K}^\intercal_{U,U_\ast}\mathbf{K}_{U,U}^{-1}\mathbf{K}_{U,U_\ast}}
  \end{split}
\label{eq:post-mean-cov}
\end{align}
```

The conditional probability of the $\mathbf{J_{U_*}}$ Equation \@ref(eq:post-mean-cov) is conditioned on $\mathcal{D}$ meaning the available data points to be inferred, and $\theta$ which is parameters of covariance function, as shown in Equation.

#### Parameter Estimation of Covariance Kernel

As it shown in the \@ref(tab:cov-tab), the Matern Covariance function with $\nu=\frac{5}{2}$ has two parameters to be estimated, namely $\sigma^2_f$ and $\ell$. GP is fit to the data by optimizing the evidence-the marginal probability of the data given the model with respect to the marginalized kernel parameters. Known as the empirical Bayes approach, we will maximize the marginal likelihood:

```{=tex}
\begin{equation}
p(\mathbf{y}|\mathbf{J_U,\mathbf{\theta}})= \int p(\mathbf{y}|\mathbf{J_U})p(\mathbf{J_U}|\mathbf{\theta})d\mathbf{J}
\label{eq:marg_like_int}
\end{equation}
```

The term $p(\mathbf{y}|\mathbf{J_U,\mathbf{\theta}})$ in fact represent the probability of observing the data $y$given on the model, $\mathbf{J_U,\mathbf{\theta}}$. The reason it is called the marginal likelihood, rather than just likelihood, is because we have marginalized out the latent Gaussian vector $\mathbf{J_U}$. The $log$ of marginal likelihood then can be written as:

```{=tex}
\begin{equation}
\text{log} \: p(\mathbf{y}|\mathbf{J_U,\mathbf{\theta}})=\mathcal{L}(\sigma_f^2,\ell)=-\frac{1}{2}(\mathbf{y}-m(\mathbf{U}))^{\intercal}\mathbf{K}_{U,U}^{-1}(\mathbf{y}-m(\mathbf{U}))-\frac{1}{2}\text{log}|\mathbf{K}_{U,U}|-\frac{N}{2}log(2\pi)
\label{eq:log_like}
\end{equation}
```

Where the dependence of the $\mathbf{K}_{U,U}$ on $\theta$ is implicit. This objective function consists of a model fit and a complexity penalty term that results in an automatic Occam's razor for realizable functions (Rasmussen and Ghahramani, 2001). By optimizing the evidence with respect to the kernel hyperparameters, we effectively learn the structure of the space of functional relationships between the inputs and the targets. The gradient-based optimizer is performed in order to:

```{=tex}
\begin{equation}
\theta^{\ast}=[\sigma_f^{2\ast}, \ell^{\ast}]=argmax \: \mathcal{L}(\sigma^2_f,\ell)
\label{eq:log-like-opt}
\end{equation}
```

However, since the objective $\mathcal{L}$ is not convex, local minima can be a problem, so we need to use multiple restarts.

It is useful to note that the value $\theta^{\ast}$ could be estimated using only a "initial data", $\mathcal{D}=[\mathbf{U},\mathbf{J_U}]$. Therefore Equation \@ref(eq:post-mean-cov) can be written using the "optimized" value of $\theta$. Moreover, given that in next step usually, we need probability distribution of $\mathbf{J}$ for each control value ($\mathbf{u}$), equation \@ref(eq:post-mean-cov) can be written as:

```{=tex}
\begin{align}
  \begin{split}
p(\mathbf{J_{u_*}}|\mathbf{\mathcal{D},\theta^\ast})= & \:  \mathcal{N}(\mathbf{J_{u_*}}| \mathbf{\mu_{u_\ast}}, \mathbf{\sigma^2_{u_{\ast}}}) \\
\mathbf{\mu_{u_\ast}}= & \:  m(\mathbf{u_\ast}) +\mathbf{K}^\intercal_{U,u_*} \mathbf{K}^{-1}_{U,U}(\mathbf{J_U}-m(\mathbf{U})) \\
\textstyle \sigma^2_{\mathbf{u_{\ast}}}=& \:  \normalsize{\mathbf{\kappa}_{u_\ast,u_\ast}-\mathbf{K}^\intercal_{U,u_\ast}\mathbf{K}_{U,U}^{-1}\mathbf{K}_{U,u_\ast}}
  \end{split}
\label{eq:post-mean-cov-single}
\end{align}
```

In \@ref(eq:post-mean-cov-single), we replaced the $\mathcal{MN}$ with $\mathcal{N}$ in \@ref(eq:post-mean-cov) as Equation \@ref(eq:post-mean-cov-single) shows the probability of $\mathbf{J}$ for *one* control variable, wherein Equation \@ref(eq:post-mean-cov) we have th probality of the $\mathbf{J}$, over a vector of the control variable, $\mathbf{U}$.

### Step.2 Deciding on next $\mathbf{u}^{next}$ based on the probabilistic model

The posterior of the probabilistic model given by Equation \@ref(eq:post-mean-cov) can quantify the uncertainty over the space of the unknown function, $f$. The question is, what is the next $\mathbf{u}^{next}$ to feed into the *expensive function*?. In other words, so far we have $\mathcal{D}$, but need to decide the next $\mathbf{u}^{next}$ so that going back to Step 1, our updated $\mathcal{D}$ be $\mathcal{D}=\mathcal{D} \: \cup[\mathbf{u^{next}},\mathbf{J(u^{next})}]$. One could select the next point arbitrarily, but that would be wasteful.

To answer this question, we define a utility function, and the next query point is the point that with maximum utility. The literature of BO has seen many utility functions (called acquisition function in the computer science community). These include the Improvement based policies (Probability of Improvement (PI), Expected Improvement(EI)), optimistic policies (Upper Confidence Bound (UCB)), or Information-based (like Thompson Sampling (TS)). The full review of these utility functions and their strength and weakness could be reviewed in [@shahriari2016].

In the Expected Improvement (EI) policy, the utility is defined as follows:

```{=tex}
\begin{equation}
utility(\mathbf{u_\ast};\theta^{\ast},\mathcal{D})=\alpha_{EI}(\mathbf{u_\ast};\theta^\ast,\mathcal{D})=\int_{y}^{}max(0,\mathbf{J_{u_*}}-f)p(\mathbf{J_{u_*}}|\mathbf{\mathcal{D},\theta^\ast}) \,dy
\label{eq:utiint}
\end{equation}
```

The utility defined in Equation \@(ref:utiint) can be seen as the expected value of improvement in posterior of the model (Equation \@ref(eq:post-mean-cov)) compared to the *true function* at point $\mathbf{u_\ast}$. Note that the term $p(\mathbf{J_{u_*}}|\mathbf{\mathcal{D},\theta^\ast})$ inside the integral already has been defined at Equation \@ref(eq:post-mean-cov). However, we do not have access to the *expensive function*, $f$; therefore, we replace the $f$ with the best available solution found so far, $\mathbf{J}^+$. The $\mathbf{J^+}$ mathematically can be defined simply as below, then Equation \@ref(eq:utiint) can be written as Equation \@ref(eq:utiint2):

```{=tex}
\begin{equation}
\begin{aligned}
\mathbf{J^+} = \; \underset{\mathbf{u} \subseteq \mathcal{D}}{\text{max}}
\; \mathbf{J(u)}
\end{aligned}
\label{eq:j-plus}
\end{equation}
```
```{=tex}
\begin{equation}
\alpha_{EI}(\mathbf{u_\ast};\theta^\ast,\mathcal{D})=\int_{y}^{}max(0,\mathbf{J_{u_*}}-\mathbf{J^+})p(\mathbf{J_{u_*}}|\mathbf{\mathcal{D},\theta^\ast}) \,dy
\label{eq:utiint2}
\end{equation}
```

After applying some tedious integration by parts on the right side of \@ref(eq:utiint2), one can express the expected improvement in a closed form [@jones1998]. To achieve closed form, first, we need some parametrization and define the $\gamma(\mathbf{u_*})$ as below:

```{=tex}
\begin{equation}
\gamma(\mathbf{u_*})=\frac{\mathbf{\mu_{u_\ast}}-\mathbf{J^+}}{\sigma_\mathbf{u_{\ast}}}
\label{eq:gamma}
\end{equation}
```

Where $\mathbf{\mu_{u_\ast}}$ and $\sigma_\mathbf{u_{\ast}}$ can be found from Eqaution \@ref(eq:post-mean-cov-single) and $\mathbf{J^+}$ has been defined in Equation \@ref(eq:j-plus). Given the $\gamma(\mathbf{u_*})$, the right side of Equation \@ref(eq:utiint2) can be written as:

```{=tex}
\begin{equation}
\alpha_{EI}(\mathbf{u_*};\theta^*,\mathcal{D})=(\mathbf{\mu_{u_\ast}}-\mathbf{J^+})\Phi(\gamma(\mathbf{u
_*})) + \sigma_{\mathbf{u_{\ast}}} \phi(\gamma(\mathbf{u_*}))
\label{eq:utility}
\end{equation}
```

Where $\Phi(.)$ and $\phi(.)$ are CDF and PDF of standard Gaussian distribution. We need to note that $\alpha_{EI}(\mathbf{u_*};\theta^*,\mathcal{D})$ is always non-negative, as the integral defined in \@ref(eq:utiint2) is truncating the negative side of the function $\mathbf{J}$ inside the $max()$ term. The Equation\@ref(eq:utility) does a fine job in many applications of Bayesian Optimization. However, the utility defined in Equation \@ref(eq:utility) sometimes can be *greedy*. In this context, greedy utility means that it is focused more on the "immediate reward", which is the first part of Equation \@ref(eq:utility), less on the "Exploration" part. Therefore to avoid this greed and make the utility function more forward-looking, an explorative term is added as $\epsilon$, and Equation \@ref(eq:gamma) can be re-written as:

```{=tex}
\begin{equation}
\gamma(\mathbf{u_*})=\frac{\mathbf{\mu_{u_\ast}}-\mathbf{J^+}-\epsilon}{\sigma^2_{\mathbf{u_{\ast}}}}
\label{eq:gamma-no-greed}
\end{equation}
```

Likewise, Expected improvement (EI) at point $\mathbf{u_*}$ can be defined then as:

```{=tex}
\begin{equation}
\alpha_{EI}(\mathbf{u_*};\theta,\mathcal{D})=(\mathbf{\mu_{u_\ast}}-\mathbf{J^+}-\epsilon)\Phi(\gamma(\mathbf{u
_*})) + \sigma_{\mathbf{u_{\ast}}} \phi(\gamma(\mathbf{u_*}))
\label{eq:utility-no-greed}
\end{equation}
```

In this work, the utility defined in Equation \@ref(eq:utility-no-greed) was considered. The data $\mathcal{D}$ was normalized to the scale of $[0,1]$. Given that scaling, $\epsilon=0.1$ was used in this work. At the end, the answer to the question of the next query is the point where the utility is maximum, can be defined as:

```{=tex}
\begin{equation}
\mathbf{u}_*^{next}=\underset{\mathbf{u_*} \in \mathbf{U_*} }{\mathrm{argmax}} \; \alpha_{EI}(\mathbf{u_*};\theta,\mathcal{D})
\label{eq:exp-easy}
\end{equation}
```

The Equation in \@ref(eq:exp-easy) represents a need for internal optimization in each iteration of BO. However, worth noting that the optimization of Equation \@ref(eq:exp-easy) is not computationally difficult for two main reasons. First, the forward evaluation of the Equation \@ref(eq:exp-easy), $\alpha_{EI}(\mathbf{u_*};\theta,\mathcal{D})$ is inexpensive. In other words, we have a simple analytical formaula for calculating the $\alpha_{EI}(\mathbf{u_*};\theta,\mathcal{D})$, as it has been provided in Equation \@ref(eq:utility-no-greed). Secondly, the exact analytical expression of the Equation \@ref(eq:utility-no-greed) is available. Authors refer to [@rasmussen2006] for detail of mathematical formulation. Having the gradient of the function in addition to inexpensive forward function, make the gradient-based method a suitable optimization choice. In this work, the quasi-Newton family of gradient based method, BFGS is used for finding $\mathbf{u}_*^{next}$. Multi-start BFGS were performed to avoid local optima points [@nocedal2006; @byrd1995].

\newpage



# Example Cases

## 1-D Toy Problem

In this section, a 1-D toy problem is considered to illustrate the BO workflow discussed in the previous section. The 1-D problem was selected since it makes it easier to visualize all the workflow steps, hence a better explanation of equations. Though, it can be seen from the 1-D problem that the workflow can easily extend to a higher dimensional problem. The *True function* to be optimized in this section has an analytical expression with the box constraints, can be shown as:

```{=tex}
\begin{equation}
\begin{aligned}
& \underset{u}{\text{maximize}}
& & \mathbf{J(u)} = 1-\frac{1}{2} \left(\frac{\sin (12\mathbf{u})}{1+\mathbf{u}} + 2\cos(7\mathbf{u})\mathbf{u}^5 + 0.7 \right)  \\
& \text{subject to}
& & 0 \leq \mathbf{u} \leq 1
\end{aligned}
\label{eq:1deq}
\end{equation}
```

Since the analytical expression of function is available and being a 1-D problem, the global optimum of the function had been found at $\mathbf{u}_M = 3.90$. The plot of the function and the optimum point has been shown in the Figure \@ref(fig:onedplot). The function in the plot has some local optimum around $\mathbf{u}=0.75$. Choosing a 1-D problem with a non-convex structure was purposeful in this example, in order to see whether BO avoids local optima and converges to a global one or not.





\begin{figure}

{\centering \includegraphics[width=0.9\linewidth]{0_Paper1_main_files/figure-latex/onedplot-1} 

}

\caption{Plot of 1-D equation with blue dash line representing the global optimum}(\#fig:onedplot)
\end{figure}

However, it is worth mentioning that the exact analytical expression of the objective function in many real-world problems is not available (black-box optimization). What is available is a *sample* of $\mathbf{U}$ and $\mathbf{J(U)}$, represented as $\mathcal{D}=[\mathbf{U},\mathbf{J(U)}]$. Therefore, in the 1-D example, in order to mimic the real world case, we sample a few points to form our $\mathcal{D}$. We know the analytical expression of the objective function and  global optimum of the objective function in hindsight, just for the case we want to compare the performance of BO workflow.

To form $\mathcal{D}=[\mathbf{U},\mathbf{J(U)}]$ as Equation \@ref(eq:init-data), a sample of five points, $\mathbf{U}=[0.05,0.2,0.5,0.6,0.95]$ was selected to  initialize the workflow. This $\mathbf{U}$ vector with their correspondent $\mathbf{J(U)}$, forms the 

$$\mathcal{D}=[\mathbf{U},\mathbf{J_U}]=[[0.05,0.2,0.5,0.6,0.95];[0.38, 0.36, 0.77,0.44, 0.16]]$$ 
In the upper plot of Figure \@ref(fig:exampleshow), green points in diamond shape show the $\mathcal{D}$. Then, we can find the $\theta^*$ through performing optimizing in Equation \@ref(eq:log-like-opt) (as it only needs $\mathcal{D})$. Having $\theta^*$, we can find the mean value of function $\mathbf{J(u^*)}$ through Equation \@ref(eq:post-mean-cov-single). This mean values ($\mathbf{\mu_{u_\ast}}$) for each $\mathbf{u^*}$ have been depicted with a red line in Figure \@ref(fig:exampleshow). The blue lines in \@ref(fig:exampleshow) represents 100 samples of $\mathbf{J_{u_*}}$ from the gaussian distribution with mean and variance defined at \@ref(eq:post-mean-cov-single) at each $\mathbf{u^*}$. The grey area represents the 95% confidence interval. At this stage, we completed step 1 of the BO.

The first point to infer from the upper plot at Figure \@ref(fig:exampleshow) is that there is no uncertainty on the points in $\mathcal{D}$. The reason for this is (as was discussed in the previous section), here we consider "noise-free" observations. Also, worth mentioning that we have a wider grey area (more uncertainty) in the areas that are more distant from the observations, simply meaning uncertainty is less in points close to observation points. When it comes to "extrapolation", meaning in the areas outside of the range of observation points, the probabilistic model shows interesting behavior on those "extreme" area (say for example two points at $\mathbf{u^*=0}$ and $\mathbf{u^*=1}$ ), the mean curve tend to move toward the mean of all observation points , here it is $\text{average}\left(\mathbf{J(U)}\right)=0.42$. Suggesting the model shows the mean-reversion behavior when it comes to extrapolation.

The lower plot at Figure \@ref(fig:exampleshow), shows the plot of utility function- Equation \@ref(eq:utility) - at each $\mathbf{u^*}$ value. As the plot suggests, the utility function ($\alpha_{EI}$) will have a multi-modal structure. Meaning the optimization process needs a multi-start gradient method (as mentioned in last part of previous section). After performing optimization of Equation \@ref(eq:exp-easy), the blue vertical dotted line shows the $\mathbf{u}_*^{next}=0.46$ which is the point where the utility function, is maximum. Then this $\mathbf{u}_*^{next}$ is feed into the true objective function in \@ref(eq:1deq), and the pair of $[(\mathbf{u}_*^{next}, \mathbf{J}(\mathbf{u}_*^{next})]$ is added to the initial data set, leaving 

$$\mathcal{D}= \mathcal{D}\: \cup[\mathbf{u}^{next},\mathbf{J(u}^{next}]=[[0.05,0.2,0.5,0.6,0.95,0.46];[0.38, 0.36, 0.77,0.44, 0.16, 0.91]]$$

We complete step 2 of the workflow at this stage, and we performed the first iteration of BO.

Looking again to the lower figure at Figure \@ref(fig:exampleshow), the utility has two modes around two sides of point $\mathbf{u_*}=0.5$, say $\mathbf{u_{0.5}^+}=0.5 + \epsilon$ and $\mathbf{u_{0.5}^-}=0.5-\epsilon$, however the point $\mathbf{u_{0.5}^-}$ is selected as the next query point. Readers can be referred to the upper plot and it is clear that there is more uncertainty around point $\mathbf{u_{0.5}^-}$ than $\mathbf{u_{0.5}^+}$ (while their mean values are the same, due to symmetry around $\mathbf{u_*}=0.5$). The utility function always looking for the point that not only maximizes the mean value but is also interested in the points that have higher variance - Equation \@ref(eq:utility) -, which is the case between two points $\mathbf{u_{0.5}^+}$ and $\mathbf{u_{0.5}^-}$.








\begin{figure}

\includegraphics[width=1\linewidth,height=0.75\textheight]{0_Paper1_main_files/figure-latex/exampleshow-1} \hfill{}

\caption{Ite1 - Top: Gaussian posterior over the initial sample points; Lower: Utility function over the x values}(\#fig:exampleshow)
\end{figure}

If we call Figure \@ref(fig:exampleshow) as iteration \# 1, now we can go back to step 1 of BO workflow and start iteration \# 2 with new $\mathcal{D}$. In Figure \@ref(fig:allinone) another two iterations have been provided. In each row, the plot on the left represents the plot of posterior written in Equation \@ref(eq:post-mean-cov-single), the right shows the utility function provided at Equation \@ref(eq:utiint). Note that in Figure \@ref(fig:allinone) all axis labels , and legend were removed, to have better visibility. (more info about each plot can be found in \@ref(fig:exampleshow)). Interesting to see that in this example case, at iteration \#2, the workflow query the point $\mathbf{u}^{next}=0.385$ which presents the best point so far found through BO workflow. Therefore, after just two iterations, we are around $\frac{x_{best}}{x_{M}}=\frac{0.385}{0.390}=98.7%$ of the global optima. Although this is the case for the 1-D problem, it clearly shows the workflow's strength to approach the global optima in as few iterations as possible. In this case after iteration\#2, the total number of times, the true objective function has been evaluated is $\text{size}(\mathcal{D}) + \text{size}(total iteration) = 5 + 2=7$.

\begin{figure}

\includegraphics[width=0.9\linewidth,height=0.9\textheight]{0_Paper1_main_files/figure-latex/allinone-1} \hfill{}

\caption{Gaussian posterior of over the initial sample points}(\#fig:allinone)
\end{figure}

Before applying the same workflow at the field scale, the 1-D example presented here offers another valuable feature of the BO workflow. Looking at \@ref(fig:allinone), we can see that the maximum of the utility function is at the iteration \# 3 is in order of $10^{-6}$ . That shows that after optimization, even the best point to be evaluated with an expensive function has very little utility. So we can safely stop the process, since querying points to be sampled from the expensive function has a negligible potential to improve our search in optimization.

\newpage


# Field Scale

## Synthetic 3D Reservoir Model

In this section, the BO workflow is applied to a synthetic 3D reservoir model. The trough introduction of the model and it's gelogical describition can be found in [@jansen2014] . Known as "Egg Model" it has a geology of channelized depositional system. The 3D model has eight water injectors and four producers wells shown in Figure \@ref(fig:eggbase). The geological model has highly permeable channels which are described by 100 equi-probable geological realizations, three of which are illustrated in left side of Figure \@ref(fig:combine).[@hong2017].

\begin{figure}

{\centering \includegraphics[width=300px]{img/egg_base} 

}

\caption{Well locations in Egg model, blue ones are injection, the red producers}(\#fig:eggbase)
\end{figure}

Relative permeabilities and the associated fractional flow curve of the model have shown in right side of Figure \@ref(fig:combine). All the wells are vertical and completed in all seven layers. The reservoir rock is assumed to be incompressible. The production from the reservoir has  life-cycle of 10 years, as it was suggested in [@jansen2014]. Here, the injection rate to be maintained over life-cycle of reservoir is going to be optimized. Thus, given eight injection wells, the optimization workflow has the eight dimention Meaning, what is the optimum injection rate for eight injector wells, for whole 10 year period of reservoir production. However, the optimization in not unbounded, the water can be adjusted from 0 to 100 m3/day, imposing a box-constrain on the optimization problem. The injectors are operated with no pressure constraint, and the producers are under a minimal BHP of 395 bars without rate constraint.

\begin{figure}

{\centering \includegraphics[width=1\linewidth]{img/combine} 

}

\caption{Left: Three geological realizations of the 3D model; Right: Rel perm and fractional flow curve}(\#fig:combine)
\end{figure}

### Well Control Optimization

Reviewing the equation raised in the section 3, here we assume that the uncertainity in $\mathbf{G}$ can be represented by sampling its pdf to obtain an ensemble of $N_e$ realizations,
$\mathbf{G}_i$, $i=1,2,\cdots,N_e$. Then, approximating the expextaion of $\mathbf{J}$ with respect to $\mathbf{G}$ can be shown as:

```{=tex}
\begin{equation}
\mathbf{\overline{J}(u)} = \frac{\sum_{i=1}^{n_e} \mathbf{J}(\mathbf{u},\mathbf{G}_i)}{n_e} 
\label{eq:npvoptrep}
\end{equation}
```

$\mathbf{u}$ is Injection rate for the each injection well, therefore the control vector, to be optimizaed in this case is defined as:

```{=tex}
\begin{equation}
\mathbf{u}=[u_{inj1},u_{inj2},u_{inj3},u_{inj4},u_{inj5},u_{inj6},u_{inj7},u_{inj8}]^{\intercal} 
\label{eq:cont-vec}
\end{equation}
```

As the \@ref(eq:npvoptrep) suggest, the $\overline{J}(u)$ need some parameters to be defined. The oil price ($P_o$), water production cost ($p_{wp}$) and water injection cost ($P_{wi}$) in $dollar/m^3$ has been provided in the Table \@ref(tab:npvparam). Also, in this work the cash flow is disconted daily and the discount factor is avilable in the \@ref(tab:npvparam). We would like to note that in this work due to avoid further computional burden in optimization process, 10 realizations of the egg model has been considered, therefore $n_e=10$ in Equation \@ref(eq:npvoptrep).

The procedure for calcuting $\mathbf{\overline{J}(u)}$ is as follows: first we decide on the $\mathbf{u}$ and write that in the *DATA* file of reservoir simulator. Then we run the file in the numerical resevoir simulators given that the production life of the resecvoir is 10 years. We repeat te simulation for all geological realizations $\mathbf{G}_i$, $i=1,2,\cdots,N_e$. Then, we have oil production, watre production and water injection as output of simulators. Then, we can insert $q_o$, $q_{wp}$ and $q_{wi}$ into eqaution \@ref(eq:npvoptrep) and \@ref(tab:npvparam) to get $\mathbf{\overline{J}(u)}$, for given $\mathbf{u}$.


\begin{table}[H]

\caption{(\#tab:npvparam)Required Parameters needed for calculation of Expected NPV}
\centering
\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X>{\raggedright}X>{\raggedright}X}
\hline
Item & Pric & Items & Value\\
\hline
P\_o & 315 & b & 8\%\\
\hline
P\_wp & 47.5 & D & 365\\
\hline
P\_wi & 12.5 & n\_e & 10\\
\hline
\end{tabu}
\end{table}

### BO Workflow

As it was discussed, the starting point of the BO workflow is to randomly sample the initial data pairs $\mathcal{D}$ which is used to build the Gaussian model of the response surface to the input variables. In this work, forty samples from the Latin hyper cube sampling (LHS) method were drawn. Note that we draw forty sample of $\mathbf{u}_i$, $i=1:40$ while each $\mathbf{u}_i$ can only take value between 10 to 100. The LHS is prefred in this work to Monte Carlo since it provides the stratification of the CDF of each variable, leading to better coverage of the input variable space. The Figure \@ref(fig:lhssampling) show the results of the $\mathbf{\overline{J}(u)}$ for each sample from LHS. Also, The maximum $\mathbf{\overline{J}(u)}$ found from sampling has been shown with blue line. Setting the specific seed number (since LHS is in itself is random process), we get the max $NPV$ achieved here was $35.65 \$MM$. Looking at Figure \@ref(fig:lhssampling) it is worth to mention that random sampling like the LHS is not helpful to consistently approach the global optimum point, as it the solution does not improve. There is a need for efficient workflow to find the optimum point while using the a few as possible sampling from real function.

\begin{figure}

{\centering \includegraphics[width=468px]{0_Paper1_main_files/figure-latex/lhssampling-1} 

}

\caption{Expected NPV as result of forty sampling from LHS}(\#fig:lhssampling)
\end{figure}

Having the initial data found through LHS, $\mathcal{D}$ in Equation \@ref(eq:init-data) we can build the probabilistic model of, representing our understinding of surface of objective function. Unfortunately, in this section we can not plot the posterior of the probabilistic model, conditioned on the above forty LHS samples, due being the space is eight-dimetional, and hard to visualize. We can refer to the Figure \@ref(fig:exampleshow) to get the idea of how plot of the probalitc model condtioned to initial point look like (at 1D case). Then, after we have the posterior model, we need to perform optimization in Equation \@ref(eq:exp-easy) to find the next $\mathbf{u^{next}}$.  the Figure \@ref(fig:lhsbayesop) shows the expected NPV found after ten sequential sampling resulted from the BO workflow. Readers are refereed to this point that in the figure, not all red points are increasing and some points are lower than previous points. The reason for this behaviour is the nature of BayesOpt algorith. We can suggest that in the points that has lower expected NPV from the previous, we may reached the lower optimum point, but those points helped us to decrease the uncertainty, which is helpful for the further sampling. We can see that after just ten evaluation of the expenside function (here it means finding the expected NPv from running 10 geological realization using flow simulation) we reach the new record Expeted NPV of $max \overline{J}(u)=36.85$$\$MM$.

\begin{figure}

{\centering \includegraphics[width=468px]{0_Paper1_main_files/figure-latex/lhsbayesop-1} 

}

\caption{Blue points represnts the sample from LHS, red points represents the samples from the BayesOpt Workflow}(\#fig:lhsbayesop)
\end{figure}

Now, as we explained in the 1-D section, the plot of the utility at each iteration could provide some useful information about the optimization process. The Figure \@ref(fig:utilitycurve) plots the $\alpha_{EI}^*(\mathcal{D}, \theta^*)$ (Equation \@ref(eq:exp-easy) )versus the ten iteration in this work. In fact the notaion $\alpha_{EI}^*$ means the optimum of the $\alpha_{EI}(u;\mathcal{D},\theta^*)$ after running multi-start (1000)- L-BFGS-B on all $u$ values. Now, we can see that in the figure the $\alpha_{EI}^*$ is decreasing going toward the zero. It can be inferred from this trend that, we are going out of the *good* $u$ values to be sampled from the expensive function, can be intepreted that we are in the vicinity of global optima, if we see after several iteration still $\alpha_{EI}^*$ is less than $10^-6$.

\begin{figure}

{\centering \includegraphics[width=468px]{0_Paper1_main_files/figure-latex/utilitycurve-1} 

}

\caption{Maximum utility at each iteration, after running L-BFGS-B to find the u with max utility, $\alpha_{EI}^*$}(\#fig:utilitycurve)
\end{figure}

Given that the BayesOpt inherintely has stochasric natrae ( from this perspective that having thje diffrenet initialization in LHS sampling will affect the final solution), in this section BayesOpt is repeated with diffret initilization. Ideally, this repeation shouwl be conducted 100 or 1000 times, to get better overview of the convergence of the algorithm given diffrent initilization. Though, because of the computional burden, in this work only three repeations were performed. optimization Repeat the Optimization, three times, in different initial design points. Figure \@ref(fig:difinit) shows results of three repeations. At each repeation (top, middle, bottom), the blue dots come from diffrente seed numbers and they are diffrente. Then, gicen that initialization $\mathcal{D}$, sequential sampling from the expenive function is perfomred, shown in the red points. Like previous case, in these repeations, 40 samples drawn from LHS algortihem, the 10 were taken thorigh BAyesOpt lagorith, totaling 50 samples. At each row of the Figure \@ref(fig:difinit), two horizontal lines show the maximum point $\overline{NPV}$ in both random sampling phase (LHS) and BayesOpt phase. As it can be noted from the Figure \@ref(fig:difinit), at each repeation, the BayesOpt will improve the solution with small sample evaluation of the $\overline{J}(u)$. Thefore, improvemnet following the BayesOpt phase indepned of the initial design, yet the bigger question is whether given different initial design, the algorithm converge the vicinity of global optima. What is refered here is that if having different initilaization will lead completely different final solution, that hints that the algorithm has a "local" search, in conrast, if the solutions leads to one specif close $u^*$, that reprsents that algorithm have a "global" view on the surface of the objective function. In the case of "global" optimization having diferent initilizatin should lead to simular final solution, since the algorithm will not get stuck in local optimum points, close to initilalized data. This is common practice in the gradient-based optimization where the algorithm is powerfull in local optimization and in order to avoid stuck in local exterme points, "multi-start" runs are performed in order to search the global point in the objective function.

\begin{figure}

{\centering \includegraphics[width=0.9\linewidth,height=0.9\textheight]{0_Paper1_main_files/figure-latex/difinit-1} 

}

\caption{BayesOpt workflow applied to Syntetic 3D model, in three different initialization}(\#fig:difinit)
\end{figure}

To further continue thiss dicussion on the effect of initialization on the final solution, the $u^*$ value for each repeatation has been show on the left side of Figure \@ref(fig:diffu). Where the $u^*$ is the vector of 8 dimention, each value shows the optimum injection rate for the 10 years life cycle of the field, in $m^3/D$. We woul like to note that the y axis was plotted from the range of 5 to 100. The reason for this is to show that in this optimization problem, injection of each wells can take any number between 5$m^3/D$ to 100 $m^3/D$, and the y axis shows the full extend of the value optimum zation worlkflow can reach. Visually, looking at the left plot at Figure \@ref(fig:diffu), we can see that the final solution of three repeations at each weels, does not differ significantly from each other . With small exception of (injection \#2), it seems all the final solutions converges to the same solution. This feature that can be loosly said as "robustness" of optimization workflow to initial design is very helpfu, from this sense that we do not neeed to resetart the optimization with different initilaization, since they all will converges to the similar solution. From this perspective, authours can infere that BayesOpt workflow can be considered as "global" optimization method, as it shows the workflow avoids stuck in local exterme pointsor saddle regions. The plot on the left side of Figure \@ref(fig:diffu) shows that mean injection rate (mean of three repeations) and erro bar at each injection wells. The bottom of error bar in this plot shows the $mean-sd$ and top of bar is $mean + sd$ . As we can see that we do not see significant variation in the final solution in each repeations, also the plots recoomnds that in the case of repeating the optimization with more than three times (like 10 or 100), it can lead to lower variation in final solution.

\begin{figure}

{\centering \includegraphics[width=0.9\linewidth]{0_Paper1_main_files/figure-latex/diffu-1} 

}

\caption{Left: final solution of optimization algorithm in three different initialization, Right: Mean and error bar of each injection rate at each injection wells}(\#fig:diffu)
\end{figure}


\newpage


\newpage

# BayesOpt performance versus other alternatives

In this section the aim is to compare the performance of the Bayesopt workflow with other available optimization algorithm commonly used for reservoir optimization under uncertainty. The literature of field development optimization enjoys wide varieties of the workflow and algorithm applied to field development. Broadly speaking those can be divided into two categories adjoint-gradient and derivative-free. Adjoint methods, such as those described in [@forouzanfar2014; @li2012; @volkov2018] can provide computational advantage in terms of efficiency. They are, however, local methods, and it is known that broad (global) searches can be advantageous in field development optimization methods.[@debrito2021] - Therefore, in this work two well-know Derivative-free optimization (DFO) methods, extensively used reservoir optimization, named Genetic Algorithm (GA) [@chai2021; @holland1992] and Particle Swarm Optimization (PSO) [@eberhart1995; @jesmani2016] have been considered. In this section we provide a brief overview of each methods, but interested readers are refereed to the original papers.[@eberhart1995; @holland1992]

## Particle Swarm Optimization (PSO)

PSO is a global stochastic search technique that operates based on analogies to the behaviors of swarms/flocks of living organisms. Originally developed by [@eberhart1995] , Considering a swarm with $P$ particles, there is a position vector $X_{i}^{t}=(x_{i1},x_{i2}, x_{i3},x_{in})^T$ and a velocity vector $V^t_i=(v_{i1},v_{i2},v_{i3},v_{in})^T$ at a $t$ iteration for each one of the $i$ particle that composes it. These vectors are updated through the dimension $j$ according to the following equations:

```{=tex}
\begin{equation}
V^{t+1}_{ij} = \omega V^{t}_{ij} + c_{1}r_{1}^{t}(pbest_{ij}-X_{ij}^t) + c_2r_2^t(gbest_j-X_{ij}^{t})
\label{eq:pso}
\end{equation}
```
where $i=1,2,..., P$ and $j =1,2,...,n$. Equation \@ref(eq:pso) explains that there are three different contributions to a particle's movement in an iteration. In the first term, the parameter $\omega$ is the inertia weight constant. In the second term, The parameter $c_1$ is a positive constant and it is an individual-cognition parameter, and it weighs the importance of particle's own previous experiences. The other parameter second term is $r_1^t$, and this is a random value parameter with [0,1] range. The third term is the social learning one. Because of it, all particles in the swarm are able to share the information of the best point achieved regardless of which particle had found it, for example, $gbestj$. Its format is just like the second term, the one regarding the individual learning. Thus, the difference $(gbest_j - X^t_{ij})$ acts as an attraction for the particles to the best point until found at some t iteration. Similarly, $c_2$ is a social learning parameter, and it weighs the importance of the global learning of the swarm. And $r_2$ plays exactly the same role as $r_1$. Where Equation \@ref(eq:psoup) updates the particle's positions. [@almeida2019]

```{=tex}
\begin{equation}
X_{ij}^{t+1} = X_{ij}^{t} + V_{ij}^{t+1}
\label{eq:psoup}
\end{equation}
```
## Genetic Algorithm (GA)

Genetic algorithm is a stochastic search algorithms that use evolutionary strategies inspired by the basic principles of biological evolution. First developed by John Holland [@holland1975] and his collaborators in the 1960s and 1970s, later has been applied for optimization and search problems @goldberg1988; @mitchell1998. The evolution process is as follow: GA starts with the generation of an initial random population of size $P$, so for step $k = 0$ we may write ${\theta_1^{(0)}; \theta_2^{(0)},\cdots, \theta_p^{(0)}}$, (step 1). The fitness of each member of the population at any step $k$, $f(\theta_i^{(k)})$, is computed and probabilities $p_i^{(k)}$ are assigned to each individual in the population, usually proportional to their fitness, (step 2). The reproducing population is formed **selection** by drawing with replacement a sample where each individual has probability of surviving equal to $p_i^{(k)}$, (step 3). A new population ${\theta_1^{(k+1)}; \theta_2^{(k+1)},\cdots, \theta_p^{(k+1)}}$ is formed from the reproducing population using crossover and mutation operators, step (4). Then, set $k = k + 1$ and the algorithm returns to the fitness evaluation step, (back to step 2). When convergence criteria are met the evolution stops, and the algorithm deliver as the optimum [@scrucca2013].



## Comparison in Fixed Reservoir Simulation Budget (N=50)

In first part of the comparison, we compare the Bayesopt with PSO and GA in fixed $\overline{J}(u)$. It means that optimization process could continue, until they use $\overline{J}(u)=50$ function evaluations. It is worth to mention that in fact $\overline{J}(u)=50$ is equal to $500$ reservoir simulations, due to number of realization, $n_e=10$ and ten computation per each $\overline{J}(u)$. Another point is parameters of PSO and GA. These two methods needs parameters to be defined by the user. In GA, these parameters are: Population Size, probability of crossover between pairs of chromosomes, probability of mutation in a parent chromosome, The number of best fitness individuals to survive at each generation. For PSO, the algorithm parameters are as below: size of the swarm, the local exploration constant, the global exploration constant.

\begin{table}

\caption{(\#tab:unnamed-chunk-12)Parameters of GA and PSO Methods}
\centering
\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\toprule
parameters & value\\
\midrule
\addlinespace[0.3em]
\multicolumn{2}{l}{\textbf{PSO}}\\
\hspace{1em}Size of the swarm & 25\\
\hspace{1em}Local exploration constant & 5+log(2)\\
\hspace{1em}Global exploration constant & 5+log(2)\\
\addlinespace[0.3em]
\multicolumn{2}{l}{\textbf{GA}}\\
\hspace{1em}Population Size & 25\\
\hspace{1em}Probability of crossover & 80\%\\
\hspace{1em}Probability of mutation & 20\%\\
\hspace{1em}Number of best fitness individuals to survive & 5\%\\
\bottomrule
\end{tabu}
\end{table}

In \@ref(fig:comp-fixbud) results of comparison has shown. As all of three algorithm is stochastic (meaning they depends on initial random samples), comparison has been repeated three times. We would like to note that in \@ref(fig:comp-fixbud) the $y$ axis is "Max NPV Reached", meaning that in each generation of GA and PSO algorithm, the "Max" of the each generation has been shown. Morever, the Figure shows that in BayesOpt method, number of $\overline{J}(u)$ grows as $n_{initial} + n_{iteration}$, which in this case in $n_{initial}=40$ and $n_{iteration}=10$, summing up to $50$. Whereas, in PSO and GA,number of $\overline{J}(u)$ grows as $n_{\text{popsize}}\times iteation$. As \@ref(fig:comp-fixbud) shows, in all repetition, the BayesOpt outperform the other two algorithms with reaching higher NPV at fixed simulation budget. Part of performance could be attributed how algorithms use forward model. In BayesOpt, after initial sampling, the algorithm sequentially query a "one" from the expensive function, while GA and PSO needs another sample size $n_p$ per each iteration.

\begin{figure}

{\centering \includegraphics[width=0.9\linewidth]{0_Paper1_main_files/figure-latex/comp-fixbud-1} 

}

\caption{Comparison of GA, PSO and BayesOpt performance at fixed function evaluation budget}(\#fig:comp-fixbud)
\end{figure}

In this work we did not suffice the comparison to only \@ref(fig:comp-freebud). In Figure \@ref(fig:comp-freebud) we further allowed the number of $\overline{J}(u)$ evaluations to 250, while keep the results of BayesOpt to the 50. Meaning that PSO and GA algorithm will enjoy another 8 iterations ($25\times8=200$) and then their results, will be compared with BayesOpt from previous section. Figure \@ref(fig:comp-freebud) does not convey a single message about performance of these methods. In \@ref(tab:comp-tab) median value of three algorithm was compared. The value in second column of \@ref(tab:comp-tab) is mean value of each optimization method. (In three repetitions, the maximum achieved NPV is a\<b\<c, b was selected). As the \@ref(tab:comp-tab) shows, the difference between the NPV value of BayesOpt is almost negligible compared to PSO and GA, while the max NPV in BayesOpt was achieved in 50 $\overline{J}(u)$ while other two in 250. In this work and optimization setting of the 3D, synthetic reservoir model, BayesOpt reaches same optimal solution, while having computaional complexity of 5X (times) less.

\begin{figure}

{\centering \includegraphics[width=0.9\linewidth]{0_Paper1_main_files/figure-latex/comp-freebud-1} 

}

\caption{Comparison of GA PSO and BayesOpt performance at fixed function evaluation budget}(\#fig:comp-freebud)
\end{figure}

\begin{table}

\caption{(\#tab:comp-tab)Summary table for comparison of GA/PSO and Bayesopt}
\centering
\begin{tabu} to \linewidth {>{\centering}X>{\centering}X>{}c}
\toprule
Optimization Method & Maximum Achieved NPV (median) & $\overline{J}(u)$ Evaluations\\
\midrule
Bayesian Optimization & 36.848 & \cellcolor{blue}{50}\\
Particle Swarm Optimization & 36.894 & \cellcolor{blue}{250}\\
Genetic Alghorithm Optimization & 36.429 & \cellcolor{blue}{250}\\
\bottomrule
\end{tabu}
\end{table}

Comparing the Final Solution $u$ of the Opt algorithms...(the Median Replication was used)


\begin{center}\includegraphics[width=468px]{0_Paper1_main_files/figure-latex/unnamed-chunk-13-1} \end{center}

\newpage


# Concluding Remarks

\newpage

# Acknowledgements

This work received support from the Research Council of Norway and the companies AkerBP, Wintershall--DEA, Vår Energy, Petrobras, Equinor, Lundin, and Neptune Energy, through the Petromaks--2 DIGIRES project (280473) (<http://digires.no>). We acknowledge the access to Eclipse licenses granted by Schlumberger.

\newpage

# References {#references .unnumbered}
