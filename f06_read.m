function res = f06_read(name, num, freq_rek_file)
fprintf('---------START---------\n');
fprintf('f06_read\n');
% Функция считывания f06
f = fopen(name,'r');
nel = length(num); % количество элементов CBUSH
%
str = ' ';
fprintf('Finde NUMBER OF ROOTS FOUND\n');
while isempty(strfind(str, 'NUMBER OF ROOTS FOUND'))
    str = fgets(f);
end;
str1 = str(76:end);
n = sscanf(str1,'%d');      % количество частот
%
fprintf('Finde R E A L   E I G E N V A L U E S\n');
while isempty(strfind(str, 'R E A L   E I G E N V A L U E S'))
    str = fgets(f);
end;
while isempty(strfind(str, 'NO.       ORDER '))
    str = fgets(f);
end;

freq = zeros(n,1);
for i = 1:n
    str = fgets(f);
    str1 = str(60:80);
    freq(i) = sscanf(str1,'%e',1);  % считывание собственных частот, Гц
%     fprintf(1, 'freq (%d) = %f Hz\n', i, freq(i));
end;
dlmwrite(freq_rek_file, freq, '\n');
%---------------------------------------------------------------------------
fprintf('Finde E L E M E N T   S T R A I N   E N E R G I E S\n');
while isempty(strfind(str, 'E L E M E N T   S T R A I N   E N E R G I E S')) && ~feof(f)
    str = fgets(f); % пролистываем до начала распечатки энергий
end;
if feof(f)
    fprintf(1, 'ERROR! NOT FOUND E L E M E N T   S T R A I N   E N E R G I E S!\n');
    error('STRAIN ENERGIES not found');
end;
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
    energies(res(:,1),i) = res(:,2);
    %
    while isempty(strfind(str, 'ELEMENT-TYPE = BUSH')) && ~feof(f)
        str = fgets(f);
    end;
end;
%
fclose(f);
res = [energy energies']';

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