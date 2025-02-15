function CFsimple

Y = load('ml.dat');

p = randperm(length(Y)); % use random permutations of Y into p

Y(:,1) = Y(p,1);
Y(:,2) = Y(p,2);
Y(:,3) = Y(p,3);

% split into 5 sets 
% PD : see notes 

numTrans = length(Y);

first=1;
offset=floor(numTrans/5);
sumAbsErr = 0;
totalTrans = 0;

for i=1:5,
    
    testY = Y(first:last,:);
    trainY = [Y(1:(first-1),:);Y((last+1):end,:)];
    
    first = first+offset;
    last = last+offset;

    trainSet = sparse(trainY(:,1),trainY(:,2),trainY(:,3));		
    % PD : same data represented in different manner
    testSet = sparse(testY(:,1),testY(:,2),testY(:,3));
        
    for trans=1:length(testY),
        
        activeUser = testY(trans,1);
        activeItem = testY(trans,2);
        activeRating = testY(trans,3);
        
        sim = computeSimilarities(activeUser,trainSet);		
        % PD : compute simularity between active user and all training users
        
        sim(activeUser)=-1;								
	% PD : high numbers -- more similar / low numbers -- less similar 
	 % PD : activeUser = 692 : here set to -1 to move to 
	 % bottom of list -- least similar
        k = 20;										
        % PD : arbitary - usually take k = 20, can use k=100, 
        % redo until  best k is in use
        
        mask = trainSet(:,activeItem)>0;						
	% PD : going through training set and checking what rating users have given to 
        % item, if =0 then no rating given
        sim(mask==0)=-1;								
	% PD : again set similarity values of non-rating users to -1 --- 
	% move to bottom of list also
               
        [s,indx]=sort(sim,'descend');						
        % PD : vector in sorted order, plus index array list of neighbors 
        % who have best similarity as descending order applied
        
        neighbours = indx(1:k);								
        % PD : pick 20 neighbors who are most similar to activeUser
        
        mask=sim(neighbours)>0;							
        % PD : be careful there may not be 20 neighbors who have rated item, 
        % so remove anyone who has rating of zero / did not rate item
        
        neighbours = neighbours(mask);					
        % PD : this is our neighbors rating listing
        
        if (length(neighbours)==0)							
        % PD : if no neighbors rated item - then use average / mid-point
            predictRating = 3;
        else
   
         predictRating = round(mean(trainSet(neighbours,activeItem)));		
        % PD : take average rating of all neighbors who have rated item - 
        % different to notes
        end										
        % PD : formula in notes - take average deviation from mean
             
       sumAbsErr = sumAbsErr+abs(predictRating-activeRating); 
       totalTrans = totalTrans+1;
       
       if (mod(totalTrans,100)==0)   
           fprintf('%e\n', sumAbsErr/totalTrans);
       end
               
    end
    
end

MAE = sumAbsErr/totalTrans;

function sim=computeSimilarities(user,trainSet)

user_row = trainSet(user,:);
sim = trainSet*user_row';
