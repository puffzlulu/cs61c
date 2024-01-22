#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head) {
    /* TODO: Implement ll_has_cycle */
    node *fast_ptr,*slow_ptr;
    fast_ptr=head->next->next;
    if(fast_ptr==NULL) return 0;
    slow_ptr=head->next;
    while(fast_ptr&&slow_ptr){
        if(fast_ptr->next==slow_ptr->next) return 1;
        fast_ptr=fast_ptr->next->next;
        slow_ptr=slow_ptr->next;
    }
    return 0;
}
