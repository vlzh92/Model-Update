function [ strtemp ] = split( str1, str2, num )

    ind = strfind(str1, str2);
    nstr = size(ind,2);
    nchar = size(str1,2);
    
    if num < nstr
        if ( num == 0 )
            ichar = 1;
        else
            ichar = ind(num)+1;
        end
    
        if ( (ind(num+1) - ichar) > 0 )  
            strtemp = str1(ichar:(ind(num+1)-1));
        else
            strtemp = '';
        end
    end
    if num == nstr
        ichar = ind(num)+1;
        strtemp = str1(ichar:nchar);
    end

end

