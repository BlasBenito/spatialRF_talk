#TRANSCRIPTION OF THE TALK "AUTOCORRELATION IN SPATIAL REGRESSION WITH RANDOM FOREST"

## TITLE SLIDE (1/35)

Hello, my name is Blas, and I am going to talk briefly about how can we incorporate spatial autocorrelation into random forest models

But before that, I would like to thank Tiago and Marta for inviting me, I appreciate it guys!

Also, I want to warn you, living in Spain for the last two years has broken my English, so please, do not hesitate to interrupt me if something is unclear.


##AVAILABILITY (2/35)

This slideshow, the code, and the data are available in a github repository. If you are not used to this tool, just follow the link, push the green button that says "Code", and push "Download ZIP". 

You can also find the slideshow online, in that link over there.


##WHAT IS SPATIAL AUTOCORRELATION AND WHY DO WE CARE? (3/35)

In modeling, spatial autocorrelation is usually perceived as an issue to fix, and I kind of want to challenge that notion.

##TOBLER'S FIRST LAW OF GEOGRAPHY (4/35)

Let's take a look at the first law of geography. It was enunciated by Waldo Tobler in a very wordy way a few years before I was born, so this old news. 

In summary, it says that similarity depends on distance.

That dependence is what we name spatial autocorrelation.


##QUANTIFYING AUTOCORRELATION WITH MORAN'S I (5/35)

We measure spatial autocorrelation in different ways, and the most popular one is Moran's I.

Let's focus on the first landscape in the left (number 1). 

To understand how much similarity depends on distance in this synthetic landscape I plot the value of every case against the distance-weighted values of their neighbors. The slope of the linear model fitted on these pairs of points is the Moran's I of the variable.

In the first landscape it is quite high. In such case we say that the variable has a high spatial autocorrelation. 

The landscape in the center has a much lower Moran's I, so we say that there is a low spatial spatial correlation, and in the third landscape the distribution of values is random, which often leads to a negative spatial autocorrelation.

Notice that these Moran's I values are referred to the immediate neighbors of each case, but what if we want or need to study spatial autocorrelation at longer distances?


##MULTISCALE (OR INCREMENTAL) MORAN'S I (6/35)

In such case we can compute Moran's I for different neigborhood distances, which gives us an idea on how much similarity changes over distance.

For example, the landscape 1 (upper right), has its maximum Moran's I at a distance of six or seven kilometers, while for the second landscape (lower left), the peak happens at a much shorter distance.


##WHAT DOES SAC REALLY REPRESENT (7/35)

So yes, that's spatial autocorrelation, and that's how we measure it. But we often overlook the meaning of spatial autocorrelation.

What does spatial autocorrelation actually represent? Well, it is the footprint of the process that generated the data of interest!

However, spatial autocorrelation also depends on the scale of observation, or the properties of the survey. For example, observing the same variable at different resolutions, or surveys based on locations that are more or less far apart is going to affect spatial autocorrelation as well, so in the end, these three things, autocorrelation, scale, and survey structure, are hard to separate in practice.


##CHOLERA MAP JOHN SNOW (1) (8/35)

A good example of spatial autocorrelation as a footprint of the process generating the data is this map of cholera cases produced by John Snow in eighteen fiftyfour. He recorded these in the Soho neighborhood, in London, and that helped him figure out that the outbreak was related with a contaminated water pump marked in red in the figure.


##CHOLERA MAP JOHN SNOW (2) (9/35)

In this particular case, it would be possible to represent the process generating the data with a map of distances to the suspect water pump, or walking distances, or any other variation.

Sometimes spatial autocorrelation is the result of the attraction effect of a focus point, might be a resource, or the source of an infectious illness.

In such cases it is easy to generate a variable to represent the process generating the data, but sometimes it gets a bit trickier.


##COLONY OF IMPERIAL CORMORANTS (1) (10/35)

For example, look at this breeding colony of imperial cormorants. There's a lot of spatial autocorrelation in the variable "nest presence", right? But there's not a focal point, a source helping organize the variable of interest.


##COLONY OF IMPERIAL CORMORANTS (2) (11/35)

If we want to predict the location of a new nest, we need to take into account the locations of the other nests around it.

But that's a bit harder to incorporate as a variable in a model when compared with the previous example, right? In the previous case, a single number, distance to the contaminated water pump, would be enough, but now we need something else.


##SPATIAL PREDICTORS (12/35)

We need spatial predictors!


##WHAT ARE SPATIAL PREDICTORS? (13/35)

Spatial predictors are variables that represent the spatial structure of the data, and when doing that, they act as proxies of the process originating the spatial autocorrelation in the data.

In the end, what we want is a set of columns representing such spatial structure, and the eigenvectors of a distance matrix can do it pretty well.


##A GOOD PAPER TO START (14/35)

I am going to give a very brief explanation, but if you want to know more, I can recommend you this paper as a good starter.


##MAIN IDEA (15/35)

The idea goes like this: the linear combinations of eigenvectors of a distance matrix represents all the possible spatial configurations of a set of points in the geographical space.


##HYPOTHETIC SPATIAL RECORDS (16/35)

We start with a set of records in the geographical space, we don't care about their values, only their locations.


##DISTANCE MATRIX (17/35)

From there, we compute the distance matrix for all pairs of records. This is our neighborhood matrix, but it needs a couple of transformations before getting to compute its eigenvectors.


##MATRIX OF WEIGHTS (18/35)

First, we transform it into a matrix of weights in which closer neighbors have larger weights than neighbors that are farther away.


##NORMALIZED AND DOUBLE-CENTERED (19/35)

Now we normalize it by its row sums, and we double-center it, meaning that the mean of its columns and rows are zero.


##EIGENVECTORS IN SPACE (20/35)

Once the matrix is transformed, we can compute its eigenvectors, via spectral decomposition. 

If we represent these eigenvectors in space using the coordinates of the observations, we get this figure.

These are named Moran's Eigenvector Maps, and their lineal combinations represent all possible spatial configurations of the data at hand.


##EIGENVECTORS WITH MORAN'S I > 0 (21/35)

However, we are not interested in all these eigenvectors, and we only use the ones with positive Moran's I.


##MODEL TRAINING (22/35)

At this point, we have these three elements:

- A response variable.
- A set of non-spatial predictors representing features of the cases, like climate, topography, or whatever else the study is focused on.
- A set of Moran's Eigenvector Maps with positive spatial autocorrelation.

From here, we can either use all Moran's Eigenvector Maps in the training data, or we can use forward or backwards selection to choose the smallest set that better represents the spatial processes hidden in the data.


##EXAMPLE WITH THE R PACKAGE spatialRF (23/35)

Now we are going to see how these ideas work in practice with random forest using the R package spatialRF


##THE R PACKAGE spatialRF (24/35)

I started working on this package once I realized that there was no easy way to work with Moran's Eigenvector Maps in machine learning models. Even when it is not yet in CRAN, it's quite mature, and it's being used in several projects. I am planning to submit it to CRAN soon though. 


##EXAMPLE DATA (25/35)

The example data comes with the package.

The response variable is the vascular plant richness of the American ecoregions,.

The predictors represent climate, human impact, and other ecoregion features that might be drivers of plant richness.

I also have the distance matrix among the edges of the polygons.


##MODELLING SETUP (26/35)

To prepare the session, after loading the library, I load the data, and save the names of the response and the predictors in character vectors.

In the object distance thresholds I am defining three distances, fifty, five hundred, and five thousand kilometers. For every distance, the code below is going to generate three different sets of Moran's Eigenvector Maps, so the model can take into account spatial processes happening at local, regional, and continental scales.


##FITTING THE MODELS (27/35)

The function rf takes the training data, the names of the response and the predictors, the distance matrix and the distance thresholds, and fits a non-spatial random forest model with the ranger package.

In the second block, I take the non spatial model and use it as input for the function rf_spatial. It reads all the arguments it needs from the non-spatial model.

It has several methods to generate and select spatial predictors. The one I have explained is named mem.moran.sequential because it is going to generate the Moran's Eigenvector Maps for every distance threshold, it's going to rank them in descending order based on their Moran's I, and it will add them one by one into the model until the model residuals show no spatial autocorrelation.


##COMPARING THE MODELS WITH SPATIAL CROSS-VALIDATION (28/35)

I am also comparing the ability of each model to generalize over data not used to train it.

The function rf_compare is going to divide the training data 100 times into a continuous training fold, in orange, and a testing fold, in grey. 

So, for every repetition, a model is fitted on the training fold, and projected and evaluated over the testing fold.

To compare the models I am using the root mean squared error, an absolute measure of error that will be in the same units as the response variables.


##MODEL COMPARISON (29/35)

This table shows a simple comparison of the non-spatial and the spatial model.

In the first column we can see that the spatial model only needed eighteen Moran's Eigenvector Maps out of six hundred and eighty one the function rf_spatial generated from the three distance thresholds.

In the second column we can see that the residuals of the non-spatial model have a positive spatial autocorrelation, while the spatial model shows a value close to zero. This is the result of the Moran's Eigenvector Maps doing their work!

The third column shows the median root mean squared error obtained by each model over a hundred repetitions of the spatial cross-validation. Notice that the error of the spatial model is slightly larger than the error of the non spatial model.


##VARIABLE IMPORTANCE (30/35)

In this slide I am plotting together the importance scores obtained by the predictors in both models, in gray the non spatial, and in orange the spatial.

We can see here that the importance scores of both models are correlated. The shift to the left of the importance scores of the spatial model happens just because it has more predictors.

If we look at the variable named spatial_predictors, it represents the importance scores of the selected Moran's Eigenvector Maps. Notice that these importance scores are often higher than the importance scores of the non-spatial predictors, meaning that processes not represented by the non-spatial predictors play an important role in driving the number of vascular plants in the American ecoregions.


##IMPORTANCE OF THE SPATIAL PREDICTORS (31/35)

Here I have plotted the importance scores of the Moran's eigenvector maps selected in the spatial model. The first number in the name of each eigenvector represents the distance for which the eigenvector was computed.

You will notice that all the selected eigenvectors were computed at a distance of 50km, that is, a very close neighborhood distance at the scale we are working here. This means that the relevant spatial processes the model is capturing here happen in the immediate neighborhood of each ecoregions.


##RESPONSE CURVES (32/35)

This plot represents the response curves of a few of the most important non-spatial predictors. You will notice that the shapes are very similar. The shift between curves in both models again happens because the spatial model has more predictors, and there are more variables contributing to the predicted values, hence the contribution of individual predictors is buffered a bit.

The important message here is that the addition of the Moran's Eigenvector Maps does not distort the response curves of the model.


##A FEW IDEAS (33/35)

Over this talk we have seen that using spatial predictors in a random forest model reduces the spatial autocorrelation of the residuals, which is good, but at the same time it hinders model transferability, which is a bummer. Probably that might not be a problem in regular surveys though, but I haven't gotten there yet.

We have also seen that adding Moran's Eigenvector Maps to a model does not distort the importance scores or the response curves, while at the same time offers valuable information about the importance of spatial processes not represented by the non spatial predictors.

It is also important to remember that this method, since it relies on distance matrices, is computationally intensive, and the total sample size we can work with depends a lot on the computational resources we have available.


##FINAL MESSAGE (34/35)

In the end, I would like this one message to stick with you.

Adding spatial predictors to machine learning models might really help us to better understand the spatio-temporal processes generating our data. 

I think that striving for more complete models is worth the effort!

##THAT'S ALL FOLKS (35/35)

That's all guys, thanks for your patience!