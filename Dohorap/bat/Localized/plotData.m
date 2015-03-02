function plotData(timescale, data, lineNames, lineColors, titleText, picFile, ylims, timewindows, pValues)
	darkGreen = [0.2 0.7 0.2];
	f = figure;
	hold all;
	for interval = 1:size(timewindows,2)
		s = timewindows(:,interval);
		xShade = [s(1) s(1) s(2) s(2)];
		yShade = [ylims(1) ylims(2) ylims(2) ylims(1)];
		pValue = pValues(interval);
		a = 1.0;
		if pValue < 0.001
			a = 0.7;
		elseif pValue < 0.005
			a = 0.5;
		elseif pValue < 0.01
			a = 0.3;
		elseif pValue < 0.05
			a = 0.1;
		end
		if a < 1.0
			fill(xShade, yShade, darkGreen, 'FaceAlpha', a);
		end
	end
	p = plot(timescale, data);
	for lineID = 1:size(p,1)
		set(p(lineID),'Color', lineColors(lineID,:));
		set(p(lineID),'LineWidth', 2);
	end
	legend(p, lineNames,'Location','NorthEast');
	xlim([-0.5, 2.5]);
	ylim(ylims);
	pbaspect([2.5 1 1]);
	xlabel('Time after condition onset in s');
	ylabel('Activation strength');
	title(titleText);
	disp('Saving...');
	print(f, '-dpng', '-r150', picFile);
	disp('Closing...');
	close(f);
end
