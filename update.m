function c = update(f_freq_r, f_freq_t, c, energy, kof)
    fprintf(1, '---------START--------\n');
    fprintf(1, 'update\n');
%   —читывание собственных частот экспериментальных и расчетных
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
%         fprintf(1, 'str = %s', str);
        freq_reckon(i) = sscanf(str,'%f');
    end;
    fclose(f);
    
    fprintf(1, 'є  reckon freq => test freq\n');
    for i = 1:length(freq_reckon)
        fprintf(1, '%d) %f Hz => %f Hz\n', i, freq_reckon(i), freq_test(i));
    end;
    
%     c(c==0) = 0.0001;
    % fprintf(1, 'length(res(:,1)) = %d\n', length(energy(2:end,1)));
    % fprintf(1, 'length(c) = %d\n', length(c));
%     rest = energy';
    % fprintf(1, 'length(resT(:,1)) = %d\n', length(rest(:,1)));
    width = length(freq_reckon);
    higth = length(energy(:,1));
%     fprintf(1,'width = %d\nhigth = %d\n', width, higth);
    % size(alpha)
%     size(c)
%     energy
    dlmwrite([f_freq_r(1:end-4) '.Stiffnes_in.txt'] , c, '\t');
    for k=1:6
        alpha = zeros(higth, width);
        for i = 1:higth
            for j = 1:width
                alpha(i,j) = energy(i,j) / 2 / freq_reckon(j);
            end
        end
        % 
%         fprintf('size alpha\n');
%         alpha
%         alpha = alpha(1:end,1:count);
%         size(alpha)
        % 
        dlmwrite([f_freq_r(1:end-4) '.alpha.txt'] , alpha, '\t');
%         dlmwrite([f_freq_r '.Matrix_2.txt'], pinv(alpha), '\t');
        % 
%         fprintf('c(1)\n');
%         size(c(1:end, 1))
%         c(1:end, 1)
%         fprintf('pinv(alpha)\n');
%         pinv(alpha)
%         fprintf('(freq_test - freq_reckon)\n');
%         freq_test - freq_reckon
%         fprintf('pinv(alpha) * (freq_test - freq_reckon)\n');
%         pinv(alpha) * (freq_test - freq_reckon)
        c(1:end,k) = c(1:end,k) + pinv(alpha') * (freq_test - freq_reckon) * kof;
        dlmwrite([f_freq_r(1:end-4) '.Delta.txt'], pinv(alpha') * (freq_test - freq_reckon) * kof ,'-append');
        %
    end;
    c(c<0) = 0;
    dlmwrite([f_freq_r(1:end-4) '.Stiffnes_out.txt'] , c, '\t');
    fprintf(1, 'update\n');
    fprintf(1, '----------END---------\n');
end

