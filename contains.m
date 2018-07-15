function bres = contains(str1,str2)

    bres = ~isempty( strfind(str1,str2) ) ;

end

