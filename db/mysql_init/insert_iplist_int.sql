INSERT INTO ip_addr_int (host,time,method,code,size)
  SELECT inet_aton(host),time,method,code,size 
  FROM ip_addr_char
  WHERE ip_addr_char.host IS NOT NULL;
