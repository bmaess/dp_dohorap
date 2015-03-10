function connectedRegions = connectRegions()
	% dorsal pathway I: pSTG - BA6v
	% dorsal pathway II: PAC - pSTG - BA44
	% ventral pathway: PAC - aSTG - BA45
	regions = {'PAC-lh','pSTG-lh','BA6v-lh','BA44-lh','aSTG-lh','BA45-lh', 'PAC-rh','pSTG-rh'};
	regionIDs    = [1,        2,         3,         4,        5,      6,       7,      8]; % Others are not relevant in speech comprehension
	% First, the most important interhemispherical connections
	interhemi = [1,7; 2,8];
	% Next, the neighbors (including a hemispheric crossing, if PAC or pSTG are involved)
	neighborsDI = [2,3; 3,8];
	neighborsDII = [1,2; 1,8; 7,2; 7,8;  2,4; 8,4];
	neighborsV =   [1,5; 7,5;            5,6];
   neighborsL = [4,6];
	% Finally, the long tracts
	longTractsDII = [1,4; 7,4];
	longTractsV = [1,6; 7,6];
	% Put everything together
	forwardConnections = [interhemi; neighborsDI; neighborsDII; neighborsV; neighborsL; longTractsDII; longTractsV];
   disp('Number of connections:');
   size(forwardConnections)
	reverseConnections = fliplr(forwardConnections);
	connections = [forwardConnections; reverseConnections];
	% Assemble a cell array
	connectedRegions = {};
	for i = 1:size(connections,1)
		connection = connections(i,:);
		connectedRegions{i,1} = regions{connection(1)};
		connectedRegions{i,2} = regions{connection(2)};
	end
end
