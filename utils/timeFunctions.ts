export const timeAgo = (datetime: string | Date): string => {
    const now = new Date();
    const then = new Date(datetime);
    const seconds = Math.floor((now.getTime() - then.getTime()) / 1000);

    let interval = Math.floor(seconds / 31536000);
    if (interval > 1) return `fa ${interval} anys`;
    if (interval === 1) return `fa 1 any`;

    interval = Math.floor(seconds / 2592000);
    if (interval > 1) return `fa ${interval} mesos`;
    if (interval === 1) return `fa 1 mes`;

    interval = Math.floor(seconds / 86400);
    if (interval > 1) return `fa ${interval} dies`;
    if (interval === 1) return `fa 1 dia`;

    interval = Math.floor(seconds / 3600);
    if (interval > 1) return `fa ${interval} hores`;
    if (interval === 1) return `fa 1 hora`;

    interval = Math.floor(seconds / 60);
    if (interval > 1) return `fa ${interval} minuts`;
    if (interval === 1) return `fa 1 minut`;

    return `fa un moment`;
};

export const formatRuntime = (minutes: number) => {
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return `${hours}h ${mins}m`
};