function T = EVfunction (mask, eval, evec)
    T = zeros(size(eval,2),3,3);
    n = 0;
    for i = 1:size(eval,2) % iterate over all voxels
        if mask(i) ~= 0 % check the brain mask to save 80% of the effort
            D = diag([eval(1,i),eval(2,i),eval(3,i)]);
            if det(D) == 0 % abort if matrix is singular (happens in less than 0.1% of all voxels)
                T(i,:,:) = zeros(3,3);
                n = n+1;
            else
                V = [evec(1,1,i),evec(1,2,i),evec(1,3,i); ...
                 evec(2,1,i),evec(2,2,i),evec(2,3,i); ...
                 evec(3,1,i),evec(3,2,i),evec(3,3,i)];
                T(i,:,:) = V*D/V;
            end;
        end;
    end;
    disp(['Tensor calculation succeded for ', num2str(100*(1-n/i)), '% of all voxels.']);
end