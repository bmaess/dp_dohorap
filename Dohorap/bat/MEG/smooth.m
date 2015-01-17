function smoothed = smooth(data)
    l = 151;
    g = gausswin(l);
    g = g ./ sum(g);
    smoothedRaw = conv(data,g);
    lh = (l-1)/2;
    smoothed = smoothedRaw(lh: size(data,2)+lh-1);
end