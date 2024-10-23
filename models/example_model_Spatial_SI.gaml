/**
* Name: firstmodel
* Based on the internal empty template. 
* Author: tenin
* Tags: 
*/


model AMAX

/* Insert your model definition here */

global{
	shape_file delegations0_shape_file <- shape_file("../includes/delegations/delegations.shp");
  //  file shape_file_highway<- file("../includes/tunisia_highway.shp");
	

	geometry shape<-envelope(delegations0_shape_file);
	geometry mybound;

	graph road_network; // graph of the road network 
	float step <- 2 #h;
	init{
	
		 
		create Delegation from:delegations0_shape_file;
		mybound<-union(Delegation );
		
		//write mybound;
       // create road from: shape_file_highway; 
        //	road_network <- as_edge_graph(road);
		create Humain number:1000{
			//location<- any_location_in(mybound);
				
				
	location <-any_location_in(one_of(Delegation).location); 
		}
		 			
		ask Humain{
			 if(flip(0.5))
  			{is_ill <- true;
  			} 
		}	
	}
}
  species Delegation {
  	int nombre_de_malade;
  	
  reflex check_malade {
  		nombre_de_malade<- (Humain overlapping self) count(each.is_ill = true);
  	}
  aspect affiche_delegation{
  		if(nombre_de_malade = 0){
  		 draw shape color:#green border:#black;
  		
  	}
  else{  		
  	   	draw shape color:#yellow border:#black;
  	}
  	}
  }
  
  species road{
  	
  	aspect affiche_road {
  		draw shape color:#red ;
  	}
  }
  
  species Humain skills: [moving]
  {
  	bool is_ill <- false;
  	geometry shape <- circle(10#m);
  	reflex deplacement
  	{
  		//location <- any_location_in(world);
  		do wander speed: 50#km/#hour  bounds:mybound ;
  	}
  	reflex contamine when:is_ill = true{
  		list<Humain> voisins <- Humain overlapping self;
  		ask voisins{
  			if(flip(1))
  			{is_ill <- true;
  			}  			
  		}
  	}
  	aspect base
  	{
  		draw shape border:#red;
  		if(is_ill = true ){
  			draw circle (10#km) color:#blue;
  			}
  			else
  			{  		draw circle (10#km) color:#yellow;
  			}
  	}
  }
  experiment maSimulation {
  	output
  	{
  		display myMap background:#white
  		{
  			species Delegation aspect:affiche_delegation ;
  			//species  road aspect: affiche_road;
  			species Humain aspect:base;
  		}
  		display chart refresh: every(10 #cycles){
  			chart "disease spreding" type: series {
  				data "susceptile" value: Humain count(each.is_ill=false)
  				color: #green marker: false ;
  				data "infected" value: Humain count(each.is_ill=true)
  				color:#red  marker: false;
  			}
  		}
  	}
  }