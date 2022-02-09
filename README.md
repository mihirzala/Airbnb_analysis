**Introduction** 
Airbnb is an online marketplace that connects people who want to rent out their homes with people looking for accommodation in that locale. It has massively disrupted the travel accommodation and rental market in the past decade. NYC being the most populous city in the United States, and one of the most popular tourism and business places globally, we decided to explore and visualize NYC Airbnb dataset using R and Tableau.    
Airbnb has been providing unique opportunities for both entrepreneurs and travelers. For the first part of our analysis, we explored various aspects of Airbnb, such as room types, accommodations, location, amenities for entrepreneurs that are looking to host their property on Airbnb as well as factors that can help travelers make best choice for their stay. 
For the second part, we decided to explore the Super Host status of Airbnb hosts. We explored the data to see if the conditions set by Airbnb for Superhost status are strictly followed for all the hosts? We also analyzed the concentration of Superhosts in NYC map and looked deep to see how being a Super Host holds value as a consumer and entrepreneur. 

**Data Preprocessing** 
The dataset we used is from ‘Inside Airbnb’, containing 37,713 records and 74 attributes. We preprocessed the data and removed 29 attributes that were either redundant or out of scope for our analysis. We transformed attributes like host_response_time, host_response_rate, price by removing special characters and converted their data type from character to numeric. As major part of our analysis focuses on Superhost status, we removed 31 NA records from ‘host_is_superhost’ attribute to get clean dataset for effective analysis. 

**Exploration Data Analysis**
Listing and Price Comparison for all 5 boroughs
Comparing the price range of private rooms in neighborhoods
Types of rooms can accommodate most people
Do the criteria set by Airbnb for Superhost are strictly followed? 
Exploring Superhost Across Boroughs

**Conclusion** 
As we go through many of the dataset provided by Airbnb, we see much different convincing evidence that were able to prove how popularity of certain areas would affect pricing as well as other aspects of listings. However, it also disproved many kinds of speculation that one would have when they hear about Airbnb in New York City. Superhost was a concept within the system that we were interested in, and it played a role. Even though we found a small number of violations, but they exist. Maybe there are some other exception rules to superhost criteria which are not known. But based on data findings, it is probably safe to say both the requirements laid out by Airbnb themselves might not be strictly followed. Also, Superhost is a factor that allows you to determine the true intention of the host, whether they are trying to provide a better experience to a person or just pursuing Airbnb as a business venture. None the less, it was a remarkably interesting find.  


