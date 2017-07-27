% Функция считывания f06
name = 'condor.f06'

f = fopen(name,'r');

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
    fprintf(1, 'freq (%d) = %f Hz\n', i, freq(i));
end;
dlmwrite('Freq_reckon.txt', freq, '\n');
