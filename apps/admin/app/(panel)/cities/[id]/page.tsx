
'use client';

import { useQuery } from "@tanstack/react-query";
import { Loader2 } from "lucide-react";
import { useParams } from "next/navigation";

import { CityForm } from "@/components/cities/city-form";

const fetchCity = async (id: string) => {
    const res = await fetch(`/api/proxy/admin/cities/${id}`);
    if (!res.ok) throw new Error('Не удалось загрузить город');
    return res.json();
};

export default function EditCityPage() {
    const params = useParams();
    const id = params.id as string;

    const { data: city, isLoading, error } = useQuery({
        queryKey: ['city', id],
        queryFn: () => fetchCity(id),
    });

    if (isLoading) {
        return (
            <div className="flex items-center justify-center p-8">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        );
    }

    if (error || !city) {
        return <div className="p-8 text-red-500">Ошибка: {error?.message || 'Город не найден'}</div>;
    }

    return (
        <div className="space-y-4 p-8">
            <h1 className="text-2xl font-bold tracking-tight">Редактировать город: {city.name_ru || 'Без названия'}</h1>
            <CityForm initialData={city} isEdit={true} />
        </div>
    );
}
