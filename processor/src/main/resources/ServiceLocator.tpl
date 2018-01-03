package ${ package };

import ${ canonicalName };
import io.toolisticon.spiap.api.Service;
import io.toolisticon.spiap.api.Services;
import io.toolisticon.spiap.api.OutOfService;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.ServiceLoader;

/**
 * A generic service locator.
 */
public class ${ simpleName }ServiceLocator {

    /**
     * Exception that is thrown if a specific service implementation can't be found.
     */
     public static class ImplementationNotFoundException extends RuntimeException{

            public ImplementationNotFoundException(String id) {
                super(String.format("Couldn't find implementation for spi ${simpleName} with id : '%s'",id));
            }

        }

    /**
     * Key class for looking checking available spi service implementations.
     */
    public static class ServiceKey {

        private final String id;
        private final String description;
        private final int priority;

        private ServiceKey(${ simpleName } serviceImpl) {

            Service serviceAnnotation = serviceImpl.getClass().getAnnotation(Service.class);
            if (serviceAnnotation == null) {
                Services servicesAnnotation = serviceImpl.getClass().getAnnotation(Services.class);
                if (servicesAnnotation != null) {
                    for (Service service : servicesAnnotation.value()) {
                        if (${ simpleName }.class.equals(service.value())) {
                            serviceAnnotation = service;
                            break;
                        }
                    }
                }
            }
            id = serviceAnnotation != null && !serviceAnnotation.id().equals("") ? serviceAnnotation.id() : serviceImpl.getClass().getCanonicalName();
            description = serviceAnnotation != null && !serviceAnnotation.description().equals("") ? serviceAnnotation.description() : "";
            priority = serviceAnnotation != null ? serviceAnnotation.priority() : 0;

        }

        public ServiceKey(String id) {
            this (id, "", null);
        }

        public ServiceKey(String id, String description, Integer priority) {
            this.id = id;
            this.description = description;
            this.priority = priority !=null ? priority : 0;
        }

        public String getId() {
            return id;
        }

        public String getDescription() {
            return description;
        }

        public int getPriority() {
            return priority;
        }


    }

   /**
    * Comparator which allows sorting of service implementations by priority.
    */
    public static class ServicePriorityComparator implements Comparator<${ simpleName }> {

        public int compare (${ simpleName } o1,${ simpleName } o2){
            if (o1 == null && o2 == null) {
                return 0;
            } else if (o1 != null && o2 == null) {
                return -1;
            } else if (o1 == null && o2 != null) {
                 return -1;
            } else {
                ServiceKey sk1 = new ServiceKey(o1);
                ServiceKey sk2 = new ServiceKey(o2);

                if (sk1.priority == sk2.priority) {
                    return 0;
                } else {
                    return sk1.getPriority() < sk2.getPriority() ? -1 : 1;
                }

            }
        }

    }

    /*
     * Get {@link ServiceKey} for all available implementations.
     * @return a list that contains ServiceKeys for all available service implementations, or an empty List if none could be found.
     */
    public static List<${ simpleName }ServiceLocator.ServiceKey> getServiceKeys() {
        List<${ simpleName }ServiceLocator.ServiceKey> result = new ArrayList<${ simpleName }ServiceLocator.ServiceKey>();

        for (${ simpleName } serviceImpl : locateAll()) {
            result.add(new ${ simpleName }ServiceLocator.ServiceKey(serviceImpl));
        }

        return result;
    }

    /**
     * locate a service implementation with a specific {@link ServiceKey}.
     *
     * @param serviceKey the service key to search
     * @return the service implementation with the service key
     * @throws ImplementationNotFoundException if either passed service key, it's id are null or if the service implementation can't be found.
     */
    public static ${ simpleName } locateByServiceKey(${ simpleName }ServiceLocator.ServiceKey serviceKey) {

        if (serviceKey == null) {
            throw new ImplementationNotFoundException(null);
        }

        return locateById(serviceKey.getId());

    }

    /**
     * locate a service implementation with a specific id.
     *
     * @param id the id to search
     * @return the service implementation with the id
     * @throws ImplementationNotFoundException if either passed id is null or if the service implementation can't be found.
     */
    public static ${ simpleName } locateById(String id) {

        if (id != null) {
            for (${ simpleName } serviceImpl : locateAll()) {

                ServiceKey sk = new ServiceKey(serviceImpl);
                if (id.equals(sk.getId())) {
                    return serviceImpl;
                }
            }
        }

        throw new ImplementationNotFoundException(id);

    }

    /**
     * Hide constructor.
     */
    private ${ simpleName }ServiceLocator() {
    }

    /**
     * Locates a service implementation.
     * The first implementation returned by the locateAll method will be returned if more than one implementation is available.
     * Successive calls may return different service implementations.
     * @return returns the first Implementation found via locateAll method call.
     **/
    public static ${ simpleName } locate() {
        final List services = locateAll();
        return services.isEmpty() ? (${ simpleName })null : (${ simpleName })services.get(0);
    }

    /**
     * Locates all available service implementations.
     * @return returns a list containing all available service implementations or an empty list, if no implementation can be found.
     */
    public static List< ${ simpleName } > locateAll() {

        final Iterator<${ simpleName }> iterator = ServiceLoader.load(${ simpleName }.class).iterator();
        final List<${ simpleName }> services = new ArrayList<${ simpleName }>();

        while (iterator.hasNext()) {
            try {

                ${ simpleName } service = iterator.next();
                if (service.getClass().getAnnotation(OutOfService.class) == null){
                    services.add(service);
                }
            }
            catch (Error e) {
                e.printStackTrace(System.err);
            }
        }

        Collections.sort(services, new ServicePriorityComparator());
        return services;

    }

}
