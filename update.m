function c = update(f_freq_t,f_freq_r, c, energy, kof)
    fprintf(1, 'update\n');
    fprintf(1, '-------START------\n');
    f = fopen('Freq_test.txt', 'r');
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

    f = fopen('Freq_reckon.txt', 'r');
    for i = 1:count
        str = fgets(f);
        freq_reckon(i) = sscanf(str,'%f');
    end;
    fclose(f);
    
    for i = 1:length(freq_reckon)
        fprintf(1, '¹ %d) %f Hz -> %f Hz', freq_reckon(i), freq_test(i));
    end;
   
    % 
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
    dlmwrite('temp/Matrix_1.txt', alpha, '\t');
    dlmwrite('temp/Matrix_2.txt', pinv(alpha), '\t');
    % 
    fprintf('c(1)\n');
    size(c(1:end, 1))
    fprintf('pinv(alpha)\n');
    size(pinv(alpha'))
    fprintf('pinv(alpha) * (freq_test - freq_reckon)\n');
    size(pinv(alpha') * (freq_test - freq_reckon))
    for i = 1:length(c(1,1:end))
        c(1:end,i) = c(1:end,i) + pinv(alpha') * (freq_reckon - freq_test) * kof;
        dlmwrite('temp/temp.txt', kof *(pinv(alpha') * (freq_reckon - freq_test))','-append');
    end; 
    % 
    c(c<1) = 0;
    fprintf(1, '--------END-------\n');
    fprintf(1, 'update\n');
end

