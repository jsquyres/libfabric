# Proposal for notification of registered memory invalidation

## Register memory as usual

```c
// Register a buffer just like I always do
fi_mr_reg(domain, buf, len, access, offset, key, flags, &mr, my_context);

// Bind that MR to an EQ with a flag saying that I want notifications upon invalidation
fi_mr_bind(&mr, &eq, FI_MR_NOTIFY_INVALIDATE);
```

This binding is what sets up the notification mechanism for this particular MR.

## App checks EQ

The user application is then responsible for calling fi_eq_read() to check for EQ events to see if memory has been invalidated.  E.g.:

```c
struct fi_mr_notify_invalid_eq {
    struct fid_domain *domain;
    struct fid_mr *mr;
    void *buf;
    size_t len;
    uint64_t access;
    uint64_t offset;
    uint64_t key;
    void *context; // from the fi_mr_reg() call
};

int MPI_Send(void *buf, ...)
{
    is_registered = false;
    if (check_mpi_reg_cache(buf)) {
        is_registered = true;

        while (fi_eq_read(eq, &event, event_buf, sizeof(event_buf), flags) > 0) {
            if (event == FI_MR_NOTIFY_INVALIDATE) {
                struct fi_mr_notify_invalidate_eq *entry = event_buf;
                // remove the MR from this entry from MPI's reg cache
            } else {
                handle_event(...);
            }
        }

        // After handling all of the events, check to ensure the
        // buffer is already registered (can probably be a bit more
        // efficient than this, but you get the idea)
        if (!check_mpi_reg_cache(buf)) {
            is_registered = false;
        }
    }

    // ...The rest of MPI_Send (but now we know for 100% sure
    // if the buffer is already registered)
}
```

## Providers

Providers are generally responsible for ensuring that events show up on the EQ when registered memory becomes invalidated.

### usnic provider plan

In the usnic provider, we'll check the ummunotify-style mmap'ed counter during `fi_eq_read()` to see if any changes have occurred down in the kernel.

If any changes have occurred, we'll make the expensive downcall/read calls to read the details of the ummunotify events from the kernel, and then stuff them into the EQ.

After processing that, let the `fi_eq_read()` progress as normal (i.e., it will see any new events that we just stuffed in there).
