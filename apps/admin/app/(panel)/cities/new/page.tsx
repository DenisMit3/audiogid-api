
import { CityForm } from "@/components/cities/city-form";

export default function NewCityPage() {
    return (
        <div className="space-y-4 p-8">
            <h1 className="text-2xl font-bold tracking-tight">Create New City</h1>
            <CityForm />
        </div>
    );
}

