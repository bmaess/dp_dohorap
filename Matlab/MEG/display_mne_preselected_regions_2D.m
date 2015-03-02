% read one MEG data file to have a full set of positions
[sen_pos, sen_dir,label] = sensor_pos_dir_label('/scr/nobel2/fahime/clozep_data/dp02a/dp02a1_ms_hp02.fif');

magidx = ~cellfun('isempty',regexp(label,'^MEG...1_01')); % finds indices of all Magnetometers
[ttheta,tphi,~]=cart2sph(sen_pos(:,1),sen_pos(:,2),sen_pos(:,3));
[sen_d2x,sen_d2y]=pol2cart(ttheta,pi/2-tphi);
sen_d2tri=delaunay(sen_d2x,sen_d2y);

figure('name','sensor_layout');
plot (sen_d2x(magidx),sen_d2y(magidx),'LineStyle','none','Marker','o')

% reads the MNE channel selection
mne_browse_raw_sel_file = '/a/sw/mne/2.7.4-3435/amd64/share/mne/mne_browse_raw/mne_browse_raw.sel';

% target_region = 'Left-frontal';
% target_region = 'Left-temporal';
% target_region = 'Left-parietal';
% target_region = 'Left-occipital';

colorlist = {[1 0 0],[0.9 0 0.9],[0 1 0],[0 0.9 0.9],...
    [1 0 0],[0.9 0 0.9],[0 1 0],[0 0.9 0.9]};
target_regions = {'Left-frontal','Left-temporal','Left-parietal','Left-occipital'...
    'Right-frontal','Right-temporal','Right-parietal','Right-occipital'};

for tr = 1:length(target_regions)
    target_region = target_regions{tr};
    syscommand = ['grep ' target_region ' ' mne_browse_raw_sel_file ];
    [status,cmdout] =system(syscommand);

    temp=regexp(cmdout,':','split');
    temp=regexprep(temp{2},' ','');
    target_chns = regexp(temp,'\|','split');
    nonmags     = ~cellfun('isempty',regexp(target_chns,'^MEG...[23]'));
    target_chns(nonmags) = [];
        
    targetidx = false(size(magidx));
    for t=target_chns
        target=t{1};
        targetidx(~cellfun('isempty',regexp(label,[target '_01'])))=true;
    end
%     title([ 'Region: ' target_region]);
    hold on
    if tr>length(target_regions)/2
    plot (sen_d2x(targetidx),sen_d2y(targetidx),'LineStyle','none','Marker','o','MarkerFaceColor',colorlist{tr}*0.8,'MarkerSize',10)
    else
    plot (sen_d2x(targetidx),sen_d2y(targetidx),'LineStyle','none','Marker','o','MarkerFaceColor',colorlist{tr},'MarkerSize',10)   
    end
    hold off
    
end
legend([{'not included'} target_regions],'Location','EastOutside');
set(gca,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{});
daspect([1 1 1])
% view([1 0 0])
