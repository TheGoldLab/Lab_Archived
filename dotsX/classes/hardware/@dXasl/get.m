function val_ = get(a, propertyName)%get method for class dXasl: query property values%   val_ = get(a, propertyName)%%   All DotsX classes have a get method which returns a specified property%   for a class instance, or a struct containing the values of all the%   properties of one or more instances.%%----------Special comments-----------------------------------------------%-%%-% overloaded get function for class dXasl%-% get the value of a particular property from%-% the specified target object%----------Special comments-----------------------------------------------%%   See also get dXasl% Copyright 2005 by Joshua I. Gold%   University of Pennsylvania% just return the value of the given fieldname%   for the given objectval_ = a(1).(propertyName);