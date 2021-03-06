function bdf_write(name, num, c, nmax, conf)
fprintf('---------START---------\n');
fprintf('bdf_write\n');
% ������� ������ bdf
fout = fopen(name,'w');
fin =  fopen('template.bdf','r');
%
% ���������� � ������ ������������ �����
while ~feof(fin)
    str = fgets(fin);
    fprintf(fout,'%s',str);
end
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
    end
    % ��� ������� CBUSH ������������ ��������� �������� ��������
    str = sprintf('PBUSH,%8d,K,',i+nmax);
    for j =1:6
%         if c(i,j) == 0
%             str2 = '';
%         else
        if conf.LOG > 3
            fprintf(1, 'i = %d; j = %d; %f\n', i, j, c(i,j));
        end
        if c(i,j) >= 0
            str2 = sprintf('%8.2e,',c(i,j));
        else
            str2 = ',';
        end
%         end;
%         fprintf('str2 = %s\n', str2);
        % ��������� ��������
        if ~isempty(str2(:) == 'e')
            ind = str2(:) == 'e' ;
            ind1 = logical(1 - ind);
            str2 = str2(ind1);
        end
        str = [str str2];
    end
    fprintf(fout,'%s\n',str);
    %
    fprintf(fout,'CBUSH,%d,%d,%d,%d,,,,%d,\n',num(i,1),i+nmax,num(i,2),num(i,3),num(i,4));
    if conf.DEBUG > 3
        fprintf(1,'bdf_write: %s\n',str);
        fprintf(1,'CBUSH,%d,%d,%d,%d,,,,%d,\n',num(i,1),i+nmax,num(i,2),num(i,3),num(i,4));
    end
%     fprintf(fout,'CBUSH,%d,%d,%d,%d,,,,,\n',num(i,1),i+nmax,num(i,2),num(i,3));
% fprintf(fout,'CBUSH,%d,%d,%d,%d,1.000000,0.0000,0.0000,\n',num(i,1),i+nmax,num(i,2),num(i,3));
%   fprintf(fout,'CBUSH,%d,%d,%d,%d,,,,1,\n',num(i,1),i+nmax,num(i,2),num(i,3));
%     fprintf(fout,'CBUSH,%d,%d,%d,%d,,,,0,\n',num(i,1),i+nmax,num(i,2),num(i,3));

end
%------------------------------------------------
fprintf(fout,'\nENDDATA\n');
fclose(fout);

fprintf('\nbdf_write\n');
fprintf('--------- END ---------\n');
end