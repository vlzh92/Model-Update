function res = bdf_input (name)
fprintf('---------START---------\n');
fprintf('bdf_input\n');

fin = fopen(name,'r');
% Подсчёт количества записей PBUSH и CBUSH
n_c = 0;  % CBUSH
n_p = 0;  % PBUSH
nmax = 0; % наибольший идентификационный номер свойства элемента во всей модели (не только PBUSH)

i = 0;
while ~feof(fin)
    fgets(fin);
    i = i + 1;
end;
fprintf('file %s have %d lines\n', name, i);
fprintf('start count CBUSH PBUSH\n');
step = fix(i/10);
ar = 0:step:10*step;
ao = ones(1, length(ar));
maxl = i;
i = 0;
fseek(fin, 0, 'bof');

while ~feof(fin)
    str = fgets(fin);
    if strfind(str, 'PBUSH') 
        n_p = n_p+1;
    else
        if strfind(str, 'CBUSH') 
            n_c = n_c+1;
        end;
    end;
    if str(1) == 'P'
        n = read_prop_num (str);
        nmax = max(nmax, n);
    end;
    if sum(i*ao==ar)
        fprintf(1, '|%.2f%', i/maxl*100);
        if i/maxl*100 > 95
            fprintf(1, '\n');
        end;
    end;
    i = i + 1;
end;
fprintf('end count CBUSH PBUSH\n');
fprintf('CBUSH = %d PBUSH = %d\n', n_c, n_p);
%
% n_p = n_p + 5;
% n_c = n_c + 5;
pbush_num = zeros(n_p,1); % массив идентификационных номеров свойств PBUSH
pbush_c   = zeros(n_p,6); % массив жесткостей PBUSH
cbush_num = zeros(n_c,4); % массив номеров CBUSH, включая собственный номер, ссылку на PBUSH, номера 2 узлов
cbush_c   = zeros(n_c,6); % массив жесткостей CBUSH
%
fseek (fin, 0, 'bof');  % переход в начало файла
fout = fopen('template.bdf', 'w');  % поток для сохранения изменяемой части bdf
ip = 0; ic = 0;
i = 0;
while ~feof(fin)
    if sum(i*ao==ar)
        fprintf(1, '|%.2f%', i/maxl*100);
        if i/maxl*100 > 95
            fprintf(1, '\n');
        end;
    end;
    i = i + 1;
    str = fgets(fin);
   
    if strfind(str, 'PBUSH') & isempty(strfind(str, '$*'))
        fprintf(1,'\nPBUSH: %s',str);
        ip = ip+1;
        res = pbush_property_read(str);     % считывание записи PBUSH
        pbush_num(ip) = res(1);
%         fprintf(1, '%d) %f %f %f %f %f %f', ip, res(2:7));
        pbush_c(ip,:) = res(2:7);
    else
        if strfind(str, 'CBUSH') & isempty(strfind(str, '$*'))
            fprintf(1,'CBUSH: %s',str);
            ic = ic+1;
            [cbush_num(ic,:)] = cbush_property_read(str);   % считывание записи CBUSH
        else
           if isempty(strfind(str, 'ENDDATA'))
               fprintf(fout,'%s',str);
           end;
        end;
    end;
end;
fclose(fin); fclose(fout);
%
% Присвоение жесткостей элементам CBUSH
for i = 1:n_c
    ind = pbush_num - cbush_num(i,2) == 0;
%     pbush_num
%     cbush_num(i,2)
    fprintf(1, 'i = %d n_c = %d\n', i, n_c);
%     pbush_c(ind,:)
%     size(cbush_c)
%     size(pbush_c)
    cbush_c(i,:) = pbush_c(ind,:);
end;
%
res = struct('nmax', nmax, 'num',cbush_num(:, [ 1 3 4]), 'c', cbush_c);

fprintf('\nbdf_input\n');
fprintf('--------- END ---------\n');
end

% =========================================================

function num = cbush_property_read (str)
% Функция считывания записи CBUSH
    if strfind(str, ',')
%         fprintf(1, '\ncbush_property_read с запятыми\n');
        [st, str] = strtok(str, ',');
        [st, str] = strtok(str, ',');
        n1 = sscanf(st,'%d');
        [st, str] = strtok(str, ',');
        n2 = sscanf(st,'%d');
        [st, str] = strtok(str, ',');
        n3 = sscanf(st,'%d');
        [st, str] = strtok(str, ',');
                n4 = sscanf(st,'%d');
    else
%         fprintf(1, '\cbush_property_read без запятых\n');
        n1 = sscanf(str(9:16) ,'%d');
        n2 = sscanf(str(17:24),'%d');
        n3 = sscanf(str(25:32),'%d');
        n4 = sscanf(str(33:40),'%d');
    end;
    num = [n1 n2 n3 n4];    
end

% =========================================================

function res = pbush_property_read (str)
% Функция считывания записи PBUSH
    l = length(str);
    while l<72 
        %str = strcat(str,char(ones(1,73-l)*49));
        str = [str, ' '];
        l = length(str);
    end;
    %
    c = zeros(1,6);

    if strfind(str, ',')
%         fprintf(1, '\npbush_property_read с запятыми\n');
        [st, str] = strtok(str, ',');
        [st, str] = strtok(str, ',');
        n = sscanf(st,'%d');
        [st, str] = strtok(str, ',');
        for i = 1:6
           [st, str] = strtok(str, ',');
           % if isempty(st), break; end;
           st = prepare_str_e(st);
           c(i) = sscanf(st, '%e');
%            fprintf(1, 'c(%d) = %e\n', i, c(i));
        end;
    else
%         fprintf(1, '\npbush_property_read без запятых\n');
        n = sscanf(str(9:16),'%d');
        for i = 1:6
            str1 = str(17+8*i:24+8*i);
            str2 = '         ';
            % Обработка 'e' в мантиссе
            metka = 0;
            for j = 1:8
                if ~metka 
                    str2(j) = str1(j);
                    if str1(j) == '.'
                        metka = 1;
                    end;
                else
                    if metka == 1
                        if str1(j) == '+' || str1(j) == '-'
                            str2(j) = 'e';
                            str2(j+1) = str1(j);
                            metka = 2;
                        else
                            str2(j) = str1(j);
                            metka = 0;
                        end;
                    else
                        if metka == 2
                            str2(j+1) = str1(j);
                        end;
                    end;
                end;
            end;
            if ~isempty(deblank(str2))
                c(i) = sscanf(str2,'%e');
            end;
        end;
    end;

    res = [n c];
end

% =========================================================
function n = read_prop_num (str)
% Вспомогательная функция для подсчёта общего количества свойств элементов
i=0;
if ~i && ~isempty(strfind(str, 'PAABSF'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PACABS'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PACBAR'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PAERO'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBAR'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBCOMP'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBEAM'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBEND'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBMSECT'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBRSECT'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PBUSH'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PCOMP'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PDAMP'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PDUMi'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PELAS'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PGAP'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PHBDY'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PINT'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PLPLANE'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PLSOLID'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PMASS'))
    i = 4;
end;
if ~i && ~isempty(strfind(str, 'PRAC'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PROD'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PSHEAR'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PSHELL'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PSOLID'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PTUBE'))
    i = 1;
end;
if ~i && ~isempty(strfind(str, 'PVISC'))
    i = 2;
end;
if ~i && ~isempty(strfind(str, 'PWELD'))
    i = 1;
end;
%
if i
    n = sscanf(str(9:16),'%d') + i-1;
else 
    n = 0;
end;
end

function str = prepare_str_e(str)
    c = 0;
    if ~isempty(strfind(str,'+'))
        c = strfind(str,'+');
    elseif ~isempty(strfind(str,'-'))
        c = strfind(str,'-');
    end;
    if c ~= 0
        str = [str(1:c-1),'e', str(c:end)];
    end;
end