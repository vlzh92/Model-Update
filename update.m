function c = update(f_freq_r, f_freq_t, c, energy, kof)
    fprintf(1, '---------START--------\n');
    fprintf(1, 'update\n');
    f = fopen(f_freq_t, 'r');
    str = ' ';
    count = 0;
    while ~feof(f)
        str = fgets(f);
        count = count + 1;
    end;
    fseek(f,0,'bof');
    freq_test = zeros(count,1);
    freq_reckon = zeros(count,1);
    for i = 1:count
        str = fgets(f);
        freq_test(i) = sscanf(str,'%f');
    end;
    fclose(f);

    f = fopen(f_freq_r, 'r');
    for i = 1:count
        str = fgets(f);
        freq_reckon(i) = sscanf(str,'%f');
    end;
    fclose(f);
    
    for i = 1:length(freq_reckon)
        fprintf(1, '%d) %f Hz => %f Hz\n', i, freq_reckon(i), freq_test(i));
    end;
   
    c(c==0) = 1;
    % fprintf(1, 'length(res(:,1)) = %d\n', length(energy(2:end,1)));
    % fprintf(1, 'length(c) = %d\n', length(c));
    rest = energy';
    % fprintf(1, 'length(resT(:,1)) = %d\n', length(rest(:,1)));
    width = length(rest(:,1));
    higth = length(energy(2:end,1));
    % fprintf(1,'width = %d\nhigth = %d\n', width, higth);
    alpha = zeros(higth, width);
    % size(alpha)
    % size(energy)
    for i = 1:higth
        for j = 1:width
            alpha(i,j) = energy(i + 1, j)/c(i);
        end
    end
    % 
    % fprintf('size alpha\n');
    alpha = alpha(1:end,1:count);
    % size(alpha)
    % 
    dlmwrite([f_freq_t '.Matrix_1.txt'] , alpha, '\t');
    dlmwrite([f_freq_t '.Matrix_2.txt'], pinv(alpha), '\t');
    % 
%     fprintf('c(1)\n');
%     size(c(1:end, 1))
%     fprintf('pinv(alpha)\n');
%     size(pinv(alpha'))
%     fprintf('pinv(alpha) * (freq_test - freq_reckon)\n');
%     size(pinv(alpha') * (freq_test - freq_reckon))
   
    for i = 1:length(c(1,1:end))
        c(1:end,i) = c(1:end,i) + pinv(alpha') * (freq_reckon - freq_test) * kof;
        dlmwrite([f_freq_t '.Delta.txt'], pinv(alpha') * (freq_reckon - freq_test) * kof ,'-append');
    end; 
    % 
    c(c<1) = 0;
    fprintf(1, 'update\n');
    fprintf(1, '----------END---------\n');
end

