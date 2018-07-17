function [ res ] = check_stiffnes( res, conf )
    num = res.num; % 1й столбец - номера элементов cbush, 2й и 3й - номера входящих в них узлов
    c = res.c;  % массив считанных жесткостей cbush  

    len = size(c,1);
    res.num(:,1)
    maxid = max(res.num(:,1));
    for i=1:len
        n = 0;
        for j = 1:6
            if c(i,j) > 0
                n = n + 1;
            end
            if n >= 2
                n = 1;
                t = zeros(1,6);
                t(j) = c(i,j);
                c(i,j) = 0;
                size(t)
                size(c)
                c(end + 1,:) = t;
                tnum = num(i,:)
                maxid = maxid + 1;
                tnum(1,1) = maxid
                num(end + 1,:) = tnum;
                res.nmax = res.nmax + 1;
            end
            if conf.DEBUG > 4
                fprintf(1, 'check_stiffnes: c(%d, %d) = %f n = %d\n', i, j, c(i,j), n);
            end        
        end
    end
    c, num
    res = struct('nmax', res.nmax,'num',num, 'c', c);
end
