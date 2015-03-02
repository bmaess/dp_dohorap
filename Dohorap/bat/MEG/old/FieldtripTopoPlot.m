function FieldtripTopoPlot(data, subject, suffix, folderComment)
    if isnumeric(subject)
        subject = [num2str(subject,'%02i'), 'a'];
    end;    
    %%
    cfg = [];
    cfg.parameter = 'avg';
    cfg.layout = 'neuromag306all.lay';
    mags = find(sum(data.grad.tra,2)==1);
    grads = find(sum(data.grad.tra,2)<1);
    cfg.channel = mags;
    switch suffix
        case 'onset'; cfg.xlim = [0.21 0.21];
        case 'feedback'; cfg.xlim = [0.16 0.16];
        case 'decision'; cfg.xlim = [0.05 0.05];
    end;
h = figure;
subplot(2,1,1);
    ft_topoplotER(cfg, data);
subplot(2,1,2);
plot(data.time,data.avg(mags,:)*1e15);
xlim([-0.5 3]);
ylim([-250 250]);
hold on
plot(cfg.xlim,[-250 250]*1e15,'Color','r');
hold off
print(h, [getenv('DOCDIR') '/fieldtripTopo' folderComment '/' subject '-ft_avg-' suffix '.png'],'-dpng');
close(h);