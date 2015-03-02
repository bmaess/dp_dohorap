subjects = 12;
grad = zeros(subjects,2,701);
mag = zeros(subjects,2,701);

h = figure;
scale = -0.2:0.001:0.5;
for subject = 1:subjects
    for trigger = 1:2
        for block = 1:2
            subjectpath = horzcat(['../dh', num2str(subject+51), 'a/']);
            if trigger == 1
                subjectfile = horzcat(['dh', num2str(subject+51), 'a', num2str(block),'_ssh00l30_son.fif']);
                suffix = '-son';
            else
                subjectfile = horzcat(['dh', num2str(subject+51), 'a', num2str(block),'_ssh00l30_feed.fif']);
                suffix = '-feed';
            end;
            data = ft_read_data(horzcat(subjectpath, subjectfile));
            graditems = sort(horzcat(2:3:305,1:3:304));
            magitems = 3:3:306;

            graddata = zeros(204,701);
            magdata = zeros(104,701);

            for i = 1:306
                magi = 1;
                gradi = 1;
                if ismember(i, magitems)
                    magdata(magi,:) = data(i,:);
                    magi = magi +1;
                end;
                if ismember(i,graditems)
                    graddata(gradi,:) = data(i,:);
                    gradi = gradi +1;
                end;
            end;

            % butterfly plot (all channels overlaid)
            grad(subject,block,:) = (mean(graddata.^2,1)).^0.5;
            mag(subject,block,:) = (mean(magdata.^2,1)).^0.5;
        end;
        plot(scale,squeeze(mean(grad(3,:,:),2)));
        print(h,horzcat([subjectpath, 'dh',num2str(subject+51),'_grad', suffix, '.png']), '-dpng');
        plot(scale,squeeze(mean(mag(3,:,:),2)));
        print(h,horzcat([subjectpath, 'dh',num2str(subject+51),'_mag', suffix, '.png']), '-dpng');
    end;
end;

plot(scale, squeeze(mean(mean(grad,1),2)));
print(h,'../overall_grad.png', '-dpng');
plot(scale, squeeze(mean(mean(mag,1),2)));
print(h,'../overall_mag.png', '-dpng');
