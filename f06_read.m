function res = f06_read(name, num, freq_rek_file)
fprintf('---------START---------\n');
fprintf('f06_read\n');
% Функция считывания f06
f = fopen(name,'r');
% mode_scan(f)
% fclose(f);
% error('Fuck');
nel = length(num); % количество элементов CBUSH
%
str = ' ';
fprintf('Finde NUMBER OF ROOTS FOUND\n');
while isempty(strfind(str, 'NUMBER OF ROOTS FOUND')) && ~feof(f)
    str = fgets(f);
end;
exeption(f,  'ERROR! NOT FOUND NUMBER OF ROOTS FOUND!');
str1 = str(76:end);
n = sscanf(str1,'%d');      % количество частот
%
fprintf('Finde R E A L   E I G E N V A L U E S\n');
while isempty(strfind(str, 'R E A L   E I G E N V A L U E S')) && ~feof(f)
    str = fgets(f);
end;
exeption(f,  'ERROR! NOT FOUND R E A L   E I G E N V A L U E S!');
while isempty(strfind(str, 'NO.       ORDER '))
    str = fgets(f);
end;
exeption(f,  'ERROR! NO.       ORDER!');

freq = zeros(n,1);
for i = 1:n
    str = fgets(f);
    str1 = str(60:end);
    freq(i) = sscanf(str1,'%e',1);  % считывание собственных частот, Гц
%     fprintf(1, 'freq (%d) = %f Hz\n', i, freq(i));
end;
dlmwrite(freq_rek_file, freq, '\n');
%---------------------------------------------------------------------------
fprintf('Finde E L E M E N T   S T R A I N   E N E R G I E S\n');
while isempty(strfind(str, 'E L E M E N T   S T R A I N   E N E R G I E S')) && ~feof(f)
    str = fgets(f); % пролистываем до начала распечатки энергий
end;
exeption(f, 'ERROR! NOT FOUND E L E M E N T   S T R A I N   E N E R G I E S!');
%
fprintf('Finde ELEMENT-TYPE = BUSH\n');
energy = zeros(n,1);
energies = zeros(nel,n);
while isempty(strfind(str, 'ELEMENT-TYPE = BUSH'))
     str = fgets(f);
end;
while ~feof(f)
    str1 = str(99:end);
    en = sscanf(str1,'%e',1);
    %
    str = fgets(f);
    i = sscanf(str(25:end),'%d',1);
    energy(i) = en;
    %
    str = fgets(f); str = fgets(f);
    res = energy_scan(f,num);
    if (~isempty(res))
        energies(res(:,1),i) = res(:,2);
    end;
    %
    while isempty(strfind(str, 'ELEMENT-TYPE = BUSH')) && ~feof(f)
        str = fgets(f);
    end;
end;
%
fclose(f);
res = [energy energies']';
dlmwrite([freq_rek_file(1:end-4) '.Energy.txt'],res,'\t');
fprintf('f06_read\n');
fprintf('--------- END ---------\n');
end

%---------------------------------------

function res = energy_scan (f, num)
% Вспомогательная функция для считывания значений энергий деформаций
% элементов, стоящих подряд в таблице
ind = []; energies = [];
ii = (1:length(num));
i = 0;
%
str = fgets(f);
% fprintf(1,'%s',str);
[A, count] = sscanf(str, '%d %e',2);
while count && isempty(strfind(str,'PAGE'))
    i = i + 1;
    %A = sscanf(str, '%d %e',2);
    n = A(1); en = A(2);
    %
    ind1 = ii(num - n == 0);
    ind = [ind ind1];
    energies = [energies en];
    %
    str = fgets(f);
    [A, count] = sscanf(str, '%d %e',2);
end;

res = [ind' energies'];
end

function [res, status] = mode_scan_str(f)
%     fprintf(1,'mode_scan_str\n');
    str = fgets(f);
    node = sscanf(str, '%d', 1);    
    [A, count] = sscanf(str, '%d %s %e %e %e %e %e %e');
%     res = A(3:end);
    res = struct('node',node, 'mode',A(3:end)');
    if count ~= 8
        status = -1;
        res = -1;
        return;
    end;
    status = 0;
end

function str = skip_to(f,str_skip)
    str = fgets(f);
    while isempty(strfind(str, str_skip)) && ~feof(f)
        str = fgets(f);
    end;
    exeption(f, [str_skip 'NOT FOUND']);
end

function [res, count] = mode_scan_block(f)
    count = 0;
    [res, status] = mode_scan_str(f);
    if status == -1
        count = 0;
        res = -1;
        return;
    end;
    count = count + 1;
    while 1
        [temp, status] = mode_scan_str(f);
        if status
            break;
        end;
        res(count + 1).node = temp.node;
        res(count + 1).mode = temp.mode;
        count = count + 1;
    end;
end

function res = mode_scan(f)
    fseek(f,0,'bof');
    acc = 1;
    n_mode_2 = 1;
    res = struct('node',{},'mode',zeros(6,1));
    while 1
        str = skip_to(f, 'R E A L   E I G E N V E C T O R   N O .');
        start = strfind(str, 'N O .') + 5;
        str = str(start:end);
        n_mode = sscanf(str, '%d');
        if n_mode ~= n_mode_2
            acc = 0;
        end;
        n_mode_2 = n_mode;
        fprintf(1,'%d\n', n_mode);
        if n_mode > 4
            break;
        end;
        skip_to(f, 'POINT ID.');
        [temp, count] = mode_scan_block(f);
        for i = 1:count
%             fprintf(1, '%d %e %e %e %e %e %e\n', temp(i).node, temp(i).mode);
            res(acc + i, n_mode).mode = temp(i).mode;
            res(acc + i, n_mode).node = temp(i).node;
        end;
%         fprintf(1,'\n###########################################################\n');
        acc = acc + count;
    end;
    acc
    size(res)

end
%
function exeption(f, str)
    if feof(f)    
        fclose(f);
        fprintf(2, [str '\n']);
        error([str '\n']);
    end;
end