export const timeAgo = (datetime: string | Date): string => {
    const now = new Date();
    const then = new Date(datetime);
    const seconds = Math.floor((now.getTime() - then.getTime()) / 1000);

    let interval = Math.floor(seconds / 31536000);
    if (interval > 1) return `hace ${interval} años`;
    if (interval === 1) return `hace 1 año`;

    interval = Math.floor(seconds / 2592000);
    if (interval > 1) return `hace ${interval} meses`;
    if (interval === 1) return `hace 1 mes`;

    interval = Math.floor(seconds / 86400);
    if (interval > 1) return `hace ${interval} días`;
    if (interval === 1) return `hace 1 día`;

    interval = Math.floor(seconds / 3600);
    if (interval > 1) return `hace ${interval} horas`;
    if (interval === 1) return `hace 1 hora`;

    interval = Math.floor(seconds / 60);
    if (interval > 1) return `hace ${interval} minutos`;
    if (interval === 1) return `hace 1 minuto`;

    return `hace un momento`;
};

export const formatRuntime = (minutes: number) => {
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return `${hours}h ${mins}m`
};