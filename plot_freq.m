function plot_freq(path_test, path, num_iter, conf)
%####################################################
%Графики сходимости функций частот
    num_freq = number_freq(path_test);
    freq_t = read_freq(path_test, num_freq);
    freq = read_all_freq(path, num_freq, num_iter);
    s = zeros(num_freq, 1);
    close all
    figure
    for i=1:num_freq
%         a=[freq_t(i) freq(i,:)]
        bbb = - ones(1,num_iter) * freq_t(i) + freq(i,:);
        s(i) = subplot(num_freq, 1, i);
        plot(1:num_iter, ones(num_iter) * 0, '--r', 1:num_iter,bbb,'b', 'LineWidth',2);
%         axis([1 num_iter min(a)*0.98 max(a)*1.02]);
        grid on;
        title(datestr(now,'yy-mmmm-dd_HH-MM-SS'));
        xlabel('Iteration','FontSize', 8);
        ylabel('Freq [Hz]','FontSize', 8);
    end;
    for i=1:num_freq
        title(s(i), ['Freq-' int2str(i)],'FontSize', 12);
    end;
%####################################################
%График целефой функции
    figure
    freq_t = freq_t * ones(1, num_iter);
    if num_freq ~= 1
        aim = sum(abs(freq_t - freq));
    else
        aim = abs(freq_t - freq);
    end;
    plot(1:num_iter, aim, 'LineWidth',2);
    axis([1 num_iter 0 max(aim)]);
    grid on;
    xlabel('Iteration','FontSize', 8);
    ylabel('Sum(Delta) [Hz]','FontSize', 8);
    title(datestr(now,'yy-mmmm-dd HH-MM-SS'));
end

function freq = read_freq(path, num)
    freq = zeros(num,1);
	f = fopen(path);
	for i = 1:num
		str = fgets(f);
		freq(i) = sscanf(str,'%e'); 
	end;
	fclose(f);
end

function freq = read_all_freq(path, num_freq, num_iter)
	freq = zeros(num_freq, num_iter);
    c=strfind(path, '\');
    c1=c(end-1)-1;
    c=c(end)+1;
	for i=1:num_iter
        str = [path(1:c1) '\' int2str(i) '\' path(c:end)];
		freq(:, i)=read_freq(str, num_freq);
	end;
end

function nf = number_freq(path)
    path
    f = fopen(path);
    nf = 0;
    while ~feof(f)
        fgets(f);
        nf = nf + 1;
    end;
    fclose(f);
end

