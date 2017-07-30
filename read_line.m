function str = read_line(path, n)
    if nargin==1
        n = 1;
    end
    res = exist(path,'file');
    if res==0
        str = [path ' NOT EXIST'];
        fprintf(2, '%s\n', str);
        str = '???';
        return;
    end;
    f = fopen(path, 'r');
    count = 0;
    while ~feof(f)
        fgets(f);
        count = count + 1;
    end;
    if n > count
        str = ['in ' path ' n = ' int2str(n) ' beyond line file (max line = ' int2str(count) ')' ];
        fprintf(2, '%s\n', str);
        str = '???';
        return;
    end;
    fseek(f,0,'bof');
    for i=1:n
        str = fgets(f);
    end;
    fclose(f);
end

