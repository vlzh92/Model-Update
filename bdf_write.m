function bdf_write(name, num, c, nmax)
fprintf('---------START---------\n');
fprintf('bdf_write\n');
% Функция записи bdf
fout = fopen(name,'w');
fin =  fopen('template.bdf','r');
%
% Считывание и запись неизменяемой части
while ~feof(fin)
    str = fgets(fin);
    fprintf(fout,'%s',str);
end;
fclose(fin);
fprintf(fout,'$\n$\n$\n');
%------------------------------------------------
nc = length(num(:,1));
step = fix(nc/10);
ar = 0:step:10*step;
ao = ones(1, length(ar));
for i = 1:nc
    if sum(i*ao==ar)
        fprintf(1, '|%.2f%', i/nc*100);
    end;
    % Для каждого CBUSH записывается отдельное свойство элемента
    str = sprintf('PBUSH,%8d,K,',i+nmax);
    for j =1:6
        str2 = sprintf('%8.2e,',c(i,j));
        % Обработка мантиссы
        if ~isempty(str2(:) == 'e')
            ind = str2(:) == 'e' ;
            ind1 = logical(1 - ind);
            str2 = str2(ind1);
        end;
        str = [str str2];
    end;
    fprintf(fout,'%s\n',str);
    %
    fprintf(fout,'CBUSH,%d,%d,%d,%d,,,,0,\n',num(i,1),i+nmax,num(i,2),num(i,3));
end;
%------------------------------------------------
fprintf(fout,'ENDDATA\n');
fclose(fout);

fprintf('\nbdf_write\n');
fprintf('--------- END ---------\n');
end